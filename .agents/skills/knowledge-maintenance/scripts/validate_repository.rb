#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "cgi"
require "json"
require "open3"
require "pathname"
require "psych"
require "rdoc"
require "rdoc/markdown"
require "rdoc/markup/to_html"
require "set"
require "uri"

ROOT = File.expand_path("../../../..", __dir__)

class RepositoryView
  attr_reader :mode

  def initialize(mode)
    @mode = mode
    @files = case mode
             when :worktree
               Dir.chdir(ROOT) do
                 Dir.glob("**/*", File::FNM_DOTMATCH)
                    .select { |path| File.file?(path) && !path.start_with?(".git/") }
               end
             when :index
               git_lines("ls-files", "--cached")
             when :head
               git_lines("ls-tree", "-r", "--name-only", "HEAD")
             else
               raise ArgumentError, "unsupported repository view: #{mode}"
             end
    @files = @files.to_set
  end

  def files(pattern)
    @files.select { |path| File.fnmatch?(pattern, path, File::FNM_PATHNAME | File::FNM_EXTGLOB) }.sort
  end

  def exist?(path)
    path = clean(path).sub(%r{/\z}, "")
    @files.include?(path) || @files.any? { |file| file.start_with?("#{path}/") }
  end

  def read(path)
    path = clean(path)
    raise "missing file in #{mode}: #{path}" unless exist?(path)

    if mode == :worktree
      return File.binread(File.join(ROOT, path)).force_encoding(Encoding::UTF_8)
    end

    spec = mode == :index ? ":#{path}" : "HEAD:#{path}"
    stdout, stderr, status = Open3.capture3("git", "show", spec, chdir: ROOT)
    raise "git show #{spec} failed: #{stderr.strip}" unless status.success?

    stdout.force_encoding(Encoding::UTF_8)
  end

  def observed_modification_date(path)
    path = clean(path)
    filesystem_path = File.join(ROOT, path)
    return nil unless File.file?(filesystem_path)
    return nil unless File.binread(filesystem_path) == read(path).b

    File.mtime(filesystem_path).to_date
  end

  private

  def clean(path)
    Pathname(path).cleanpath.to_s.sub(%r{\A\./}, "")
  end

  def git_lines(*args)
    stdout, stderr, status = Open3.capture3("git", *args, chdir: ROOT)
    raise "git #{args.join(' ')} failed: #{stderr.strip}" unless status.success?

    stdout.lines(chomp: true).reject(&:empty?)
  end
end

class SchemaValidator
  def initialize(schema)
    @root = schema
  end

  def validate(instance)
    check(instance, @root, "$", @root)
  end

  private

  def check(value, schema, path, root)
    return [] unless schema.is_a?(Hash)

    errors = []
    if schema.key?("$ref")
      target = resolve_ref(schema.fetch("$ref"), root)
      errors.concat(check(value, target, path, root))
      schema = schema.reject { |key, _| key == "$ref" }
    end

    errors << "#{path}: expected const #{schema['const'].inspect}" if schema.key?("const") && value != schema["const"]
    errors << "#{path}: value is not in enum" if schema.key?("enum") && !schema["enum"].include?(value)
    errors << "#{path}: expected type #{schema['type']}" if schema.key?("type") && !type_match?(value, schema["type"])

    if schema.key?("oneOf")
      matches = schema["oneOf"].count { |candidate| check(value, candidate, path, root).empty? }
      errors << "#{path}: expected exactly one oneOf match, got #{matches}" unless matches == 1
    end
    Array(schema["allOf"]).each { |candidate| errors.concat(check(value, candidate, path, root)) }
    if schema.key?("not") && check(value, schema["not"], path, root).empty?
      errors << "#{path}: value matches forbidden schema"
    end
    if schema.key?("if")
      branch = check(value, schema["if"], path, root).empty? ? schema["then"] : schema["else"]
      errors.concat(check(value, branch, path, root)) if branch
    end

    if value.is_a?(Hash)
      Array(schema["required"]).each do |key|
        errors << "#{path}: missing required property #{key}" unless value.key?(key)
      end
      properties = schema.fetch("properties", {})
      properties.each do |key, child_schema|
        errors.concat(check(value[key], child_schema, "#{path}.#{key}", root)) if value.key?(key)
      end
      if schema["additionalProperties"] == false
        (value.keys - properties.keys).each { |key| errors << "#{path}: unexpected property #{key}" }
      end
    elsif value.is_a?(Array)
      errors << "#{path}: expected at least #{schema['minItems']} items" if schema["minItems"] && value.length < schema["minItems"]
      if schema["uniqueItems"] && value.map { |item| canonical(item) }.uniq.length != value.length
        errors << "#{path}: array items are not unique"
      end
      value.each_with_index { |item, index| errors.concat(check(item, schema["items"], "#{path}[#{index}]", root)) } if schema["items"]
      if schema["contains"] && value.none? { |item| check(item, schema["contains"], path, root).empty? }
        errors << "#{path}: no item matches contains"
      end
    elsif value.is_a?(String)
      errors << "#{path}: string is shorter than #{schema['minLength']}" if schema["minLength"] && value.length < schema["minLength"]
      errors << "#{path}: string does not match #{schema['pattern']}" if schema["pattern"] && !Regexp.new(schema["pattern"]).match?(value)
      errors << "#{path}: expected an ISO YYYY-MM-DD date" if schema["format"] == "date" && !valid_date?(value)
    end

    errors
  end

  def resolve_ref(ref, root)
    raise "unsupported external schema ref: #{ref}" unless ref.start_with?("#/")

    ref.delete_prefix("#/").split("/").reduce(root) do |cursor, token|
      cursor.fetch(token.gsub("~1", "/").gsub("~0", "~"))
    end
  end

  def type_match?(value, type)
    Array(type).any? do |candidate|
      case candidate
      when "object" then value.is_a?(Hash)
      when "array" then value.is_a?(Array)
      when "string" then value.is_a?(String)
      when "integer" then value.is_a?(Integer)
      when "number" then value.is_a?(Numeric)
      when "boolean" then value == true || value == false
      when "null" then value.nil?
      else false
      end
    end
  end

  def valid_date?(value)
    return false unless /\A\d{4}-\d{2}-\d{2}\z/.match?(value)

    Date.iso8601(value)
    true
  rescue Date::Error
    false
  end

  def canonical(value)
    case value
    when Hash
      value.keys.sort.to_h { |key| [key, canonical(value[key])] }
    when Array
      value.map { |item| canonical(item) }
    else
      value
    end
  end
end

Artifact = Struct.new(:path, :data, :body, :kind, keyword_init: true)

class RepositoryValidator
  attr_reader :warnings

  SCHEMA_FILES = {
    domain: "schemas/domain.schema.json",
    map: "schemas/map.schema.json",
    graph: "schemas/graph.schema.json",
    roadmap: "schemas/roadmap.schema.json",
    inbox: "schemas/inbox-frontmatter.schema.json",
    investigation: "schemas/investigation-frontmatter.schema.json",
    knowledge_note: "schemas/knowledge-note-frontmatter.schema.json",
    lab: "schemas/lab-frontmatter.schema.json"
  }.freeze

  TEMPLATE_FILES = {
    "templates/domain.yaml" => :domain,
    "templates/map.yaml" => :map,
    "templates/graph.yaml" => :graph,
    "templates/roadmap.yaml" => :roadmap,
    "templates/inbox.md" => :inbox,
    "templates/investigation.md" => :investigation,
    "templates/knowledge-note.md" => :knowledge_note,
    "templates/lab.md" => :lab
  }.freeze

  INSTANCE_PATTERNS = {
    domain: "domains/*/domain.yaml",
    map: "domains/*/map.yaml",
    graph: "domains/*/graph.yaml",
    roadmap: "domains/*/roadmaps/*.yaml",
    inbox: "inbox/*.md",
    investigation: "investigations/*.md",
    knowledge_note: "domains/*/knowledge/*.md",
    lab: "labs/*/README.md"
  }.freeze

  def initialize(view, baseline: nil, migrations: {})
    @view = view
    @baseline = baseline || (view.mode == :head ? nil : RepositoryView.new(:head))
    @migrations = migrations.freeze
    @reverse_migrations = migrations.invert.freeze
    @errors = []
    @warnings = []
    @schemas = {}
    @artifacts = []
    @baseline_artifacts = {}
  end

  def run
    load_schemas
    validate_schema_versions
    validate_templates
    load_instances
    validate_migration_mappings
    validate_cross_file_rules
    validate_markdown_links
    @errors
  end

  private

  def error(path, message)
    @errors << "#{path}: #{message}"
  end

  def warning(path, message)
    @warnings << "#{path}: #{message}"
  end

  def load_schemas
    SCHEMA_FILES.each do |kind, path|
      begin
        @schemas[kind] = JSON.parse(@view.read(path))
      rescue StandardError => e
        error(path, "invalid JSON Schema: #{e.message}")
      end
    end
  end

  def validate_schema_versions
    return if @view.mode == :head

    baseline = @baseline
    SCHEMA_FILES.each do |kind, path|
      next unless @schemas[kind] && baseline.exist?(path)

      old_schema = JSON.parse(baseline.read(path))
      next if validation_semantics(old_schema) == validation_semantics(@schemas[kind])

      old_version = old_schema.dig("properties", "schema_version", "const")
      new_version = @schemas[kind].dig("properties", "schema_version", "const")
      if old_version.is_a?(Integer) && new_version.is_a?(Integer) && new_version <= old_version
        error(path, "validation semantics changed without incrementing schema_version (#{old_version} -> #{new_version})")
      end
    rescue JSON::ParserError => e
      error(path, "cannot compare Schema version: #{e.message}")
    end
  end

  def validation_semantics(value, parent_key = nil)
    case value
    when Hash
      ignored = %w[$id $schema $comment description examples title]
      value.keys.reject { |key| ignored.include?(key) }.sort.to_h do |key|
        [key, validation_semantics(value[key], key)]
      end
    when Array
      normalized = value.map { |item| validation_semantics(item) }
      if %w[allOf anyOf enum oneOf required type].include?(parent_key)
        normalized.sort_by { |item| JSON.generate(item) }
      else
        normalized
      end
    else
      value
    end
  end

  def validate_templates
    TEMPLATE_FILES.each do |path, kind|
      unless @view.exist?(path)
        error(path, "missing required template")
        next
      end
      next unless @schemas[kind]

      artifact = parse_artifact(path, kind)
      validate_schema(artifact, @schemas[kind]) if artifact
    end
  end

  def load_instances
    INSTANCE_PATTERNS.each do |kind, pattern|
      @view.files(pattern).each do |path|
        artifact = parse_artifact(path, kind)
        next unless artifact

        @artifacts << artifact
        validate_schema(artifact, @schemas[kind]) if @schemas[kind]
      end
    end
  end

  def validate_migration_mappings
    return if @migrations.empty? || !@baseline

    baseline_ids = repository_primary_ids(baseline_instance_artifacts)
    current_ids = repository_primary_ids(@artifacts)
    @migrations.each do |old_id, new_id|
      error("migration", "source ID does not exist in Formal Baseline: #{old_id}") unless baseline_ids.include?(old_id)
      error("migration", "target ID does not exist in candidate view: #{new_id}") unless current_ids.include?(new_id)
      error("migration", "source ID still exists in candidate view: #{old_id}") if current_ids.include?(old_id)
      if baseline_ids.include?(new_id) && !@migrations.key?(new_id)
        error("migration", "target ID already existed in Formal Baseline: #{new_id}")
      end
    end
  end

  def repository_primary_ids(artifacts)
    artifacts.each_with_object(Set.new) do |artifact, ids|
      ids << artifact.data["id"] if artifact.data["id"]
      next unless artifact.kind == :map

      Array(artifact.data["nodes"]).each { |node| ids << node["id"] if node["id"] }
    end
  end

  def baseline_instance_artifacts
    INSTANCE_PATTERNS.keys.flat_map { |kind| baseline_artifacts(kind) }
  end

  def parse_artifact(path, kind)
    raw = @view.read(path)
    yaml, body = if path.end_with?(".md")
                   match = raw.match(/\A---\s*\n(.*?)\n---\s*\n/m)
                   unless match
                     error(path, "missing or malformed YAML frontmatter")
                     return nil
                   end
                   [match[1], raw[match.end(0)..] || ""]
                 else
                   [raw, ""]
                 end
    reject_yaml_extensions(yaml, path)
    reject_yaml_style(yaml, path)
    data = Psych.safe_load(yaml, permitted_classes: [], permitted_symbols: [], aliases: false)
    unless data.is_a?(Hash)
      error(path, "YAML root must be an object")
      return nil
    end
    Artifact.new(path: path, data: data, body: body, kind: kind)
  rescue Psych::Exception => e
    error(path, "invalid or unsafe YAML: #{e.message}")
    nil
  end

  def reject_yaml_extensions(yaml, path)
    root = Psych.parse_stream(yaml)
    walk = lambda do |node|
      if node.respond_to?(:anchor) && node.anchor
        error(path, "YAML anchors and aliases are forbidden")
      end
      if node.respond_to?(:tag) && node.tag && !node.tag.start_with?("tag:yaml.org,2002:")
        error(path, "custom YAML tags are forbidden: #{node.tag}")
      end
      Array(node.respond_to?(:children) ? node.children : []).each { |child| walk.call(child) }
    end
    walk.call(root)
  end

  def reject_yaml_style(yaml, path)
    yaml.lines.each_with_index do |line, index|
      next if line.strip.empty?

      leading = line[/\A[ \t]*/]
      error(path, "line #{index + 1} uses tabs for YAML indentation") if leading.include?("\t")
      spaces = leading.count(" ")
      error(path, "line #{index + 1} does not use two-space YAML indentation") unless spaces.even?
    end
  end

  def validate_schema(artifact, schema)
    SchemaValidator.new(schema).validate(artifact.data).each { |message| error(artifact.path, message) }
  end

  def validate_cross_file_rules
    by_kind = @artifacts.group_by(&:kind)
    domains = index_unique(by_kind[:domain], "id")
    maps = index_unique(by_kind[:map], "domain")
    graphs = index_unique(by_kind[:graph], "domain")
    index_unique(by_kind[:roadmap], "id")
    notes = index_unique(by_kind[:knowledge_note], "id")
    inboxes = index_unique(by_kind[:inbox], "path")
    investigations = index_unique(by_kind[:investigation], "path")
    labs = index_unique(by_kind[:lab], "path")

    nodes = {}
    Array(by_kind[:map]).each do |map|
      domain = map.data["domain"]
      directory = map.path.split("/")[1]
      error(map.path, "domain does not match directory") if domain != directory
      error(map.path, "missing matching domain.yaml") unless domains.key?(domain)
      local = {}
      Array(map.data["nodes"]).each do |node|
        id = node["id"]
        error(map.path, "duplicate node ID #{id}") if nodes.key?(id) || local.key?(id)
        error(map.path, "node #{id} has wrong Domain prefix") unless id&.start_with?("#{domain}.")
        local[id] = node
        nodes[id] = { node: node, map: map }
      end
      local.each do |id, node|
        parent = node["parent"]
        error(map.path, "node #{id} has missing or cross-Map parent #{parent}") if parent && !local.key?(parent)
      end
      detect_parent_cycles(map, local)
    end

    Array(by_kind[:domain]).each do |domain|
      id = domain.data["id"]
      directory = domain.path.split("/")[1]
      error(domain.path, "Domain ID does not match directory") if id != directory
      error(domain.path, "missing map.yaml") unless maps.key?(id)
      error(domain.path, "missing graph.yaml") unless graphs.key?(id)
    end

    validate_graphs(by_kind[:graph], nodes, domains)
    validate_roadmaps(by_kind[:roadmap], nodes, notes, domains)
    validate_notes(by_kind[:knowledge_note], nodes)
    validate_paths(by_kind)
    validate_investigations(by_kind, nodes, notes, inboxes, investigations, labs, domains)
    validate_labs(by_kind[:lab], nodes, notes, investigations, domains)
    validate_note_links(by_kind[:knowledge_note], investigations, labs)
    validate_archived_domains(by_kind, domains, notes, investigations, labs)
    validate_terminal_transitions(by_kind)
    validate_updated_at(by_kind)
  end

  def index_unique(artifacts, field)
    index = {}
    Array(artifacts).each do |artifact|
      key = field == "path" ? artifact.path : artifact.data[field]
      error(artifact.path, "duplicate #{field} #{key}") if index.key?(key)
      index[key] = artifact
    end
    index
  end

  def detect_parent_cycles(map, local)
    local.each_key do |start|
      seen = Set.new
      cursor = start
      while cursor
        if seen.include?(cursor)
          error(map.path, "Map parent cycle reaches #{cursor}")
          break
        end
        seen << cursor
        cursor = local[cursor] && local[cursor]["parent"]
      end
    end
  end

  def validate_graphs(graphs, nodes, domains)
    prerequisites = []
    Array(graphs).each do |graph|
      domain = graph.data["domain"]
      directory = graph.path.split("/")[1]
      error(graph.path, "domain does not match directory") if domain != directory
      error(graph.path, "missing matching Domain") unless domains.key?(domain)
      semantic = Set.new
      Array(graph.data["edges"]).each do |edge|
        from, to, type = edge.values_at("from", "to", "type")
        error(graph.path, "self edge #{from}") if from == to
        error(graph.path, "missing edge endpoint #{from}") unless nodes.key?(from)
        error(graph.path, "missing edge endpoint #{to}") unless nodes.key?(to)
        key = type == "related" ? [type, from, to].sort.join("|") : [type, from, to].join("|")
        error(graph.path, "duplicate semantic edge #{from} #{type} #{to}") if semantic.include?(key)
        semantic << key
        if type == "related"
          error(graph.path, "related edge is not in canonical order") unless from && to && from < to
          error(graph.path, "cross-Domain related edge is forbidden") unless node_domain(from) == domain && node_domain(to) == domain
        elsif type == "prerequisite"
          error(graph.path, "prerequisite target is not owned by this Graph") unless node_domain(to) == domain
          prerequisites << [from, to, graph.path]
        end
      end
    end
    detect_prerequisite_cycles(prerequisites)
  end

  def detect_prerequisite_cycles(edges)
    adjacency = Hash.new { |hash, key| hash[key] = [] }
    edges.each { |from, to, _| adjacency[from] << to }
    visiting = Set.new
    visited = Set.new
    visit = lambda do |node|
      return if visited.include?(node)
      if visiting.include?(node)
        error("graphs", "global prerequisite cycle reaches #{node}")
        return
      end
      visiting << node
      adjacency[node].each { |child| visit.call(child) }
      visiting.delete(node)
      visited << node
    end
    adjacency.each_key { |node| visit.call(node) }
  end

  def validate_roadmaps(roadmaps, nodes, notes, domains)
    Array(roadmaps).each do |roadmap|
      data = roadmap.data
      domain = data["domain"]
      directory = roadmap.path.split("/")[1]
      error(roadmap.path, "domain does not match directory") if domain != directory
      error(roadmap.path, "Roadmap ID has wrong Domain prefix") unless data["id"]&.start_with?("#{domain}.")
      error(roadmap.path, "missing matching Domain") unless domains.key?(domain)
      phase_ids = Set.new
      item_nodes = Set.new
      Array(data["phases"]).each do |phase|
        error(roadmap.path, "duplicate phase ID #{phase['id']}") if phase_ids.include?(phase["id"])
        phase_ids << phase["id"]
        Array(phase["items"]).each do |item|
          node = item["node"]
          error(roadmap.path, "duplicate Roadmap node #{node}") if item_nodes.include?(node)
          item_nodes << node
          error(roadmap.path, "Roadmap node #{node} is not owned by #{domain}") unless nodes.key?(node) && node_domain(node) == domain
          note = notes[node]
          if item["status"] == "in_progress"
            error(roadmap.path, "in_progress node #{node} has no Note") unless note
            error(roadmap.path, "in_progress node #{node} has an ineligible Note") if note && %w[archived superseded].include?(note.data["maturity"])
          elsif item["status"] == "completed"
            error(roadmap.path, "completed node #{node} has no Note") unless note
          end
        end
      end
    end
  end

  def validate_notes(notes, nodes)
    Array(notes).each do |note|
      id = note.data["id"]
      domain = note.data["domain"]
      error(note.path, "Note ID references missing Map node") unless nodes.key?(id)
      error(note.path, "Note domain does not match ID") unless node_domain(id) == domain
    end
    validate_replacement_chains(Array(notes).to_h { |note| [note.data["id"], note] })
  end

  def validate_replacement_chains(notes)
    notes.each_value do |note|
      next unless note.data["maturity"] == "superseded"

      seen = Set.new
      cursor = note
      loop do
        id = cursor.data["id"]
        if seen.include?(id)
          error(note.path, "superseded replacement cycle reaches #{id}")
          break
        end
        seen << id
        target_id = cursor.data["superseded_by"]
        target = notes[target_id]
        unless target
          error(note.path, "missing superseded target #{target_id}")
          break
        end
        if target.data["maturity"] == "superseded"
          cursor = target
          next
        end
        eligible = target.data["maturity"] == "published" ||
                   (%w[draft reviewed].include?(target.data["maturity"]) && target.data["knowledge_cycle"] == "revision")
        error(note.path, "replacement endpoint #{target_id} is not eligible") unless eligible
        break
      end
    end
  end

  def validate_paths(by_kind)
    Array(by_kind[:knowledge_note]).each do |note|
      expected = "domains/#{note.data['domain']}/knowledge/#{note.data['id'].to_s.split('.', 2)[1]}.md"
      error(note.path, "expected path #{expected}") unless note.path == expected
    end
    Array(by_kind[:inbox]).each do |inbox|
      match = inbox.data["id"].to_s.match(/\Ainbox\.(\d{4}-\d{2}-\d{2})\.(.+)\z/)
      expected = match && "inbox/#{match[1]}-#{match[2]}.md"
      error(inbox.path, "Inbox ID/path mismatch") unless expected == inbox.path
    end
    Array(by_kind[:investigation]).each do |investigation|
      slug = investigation.data["id"].to_s.delete_prefix("investigation.")
      error(investigation.path, "Investigation ID/path mismatch") unless investigation.path == "investigations/#{slug}.md"
    end
    Array(by_kind[:lab]).each do |lab|
      slug = lab.data["id"].to_s.delete_prefix("lab.")
      error(lab.path, "Lab ID/path mismatch") unless lab.path == "labs/#{slug}/README.md"
    end
  end

  def validate_investigations(by_kind, nodes, notes, inboxes, investigations, labs, domains)
    Array(by_kind[:inbox]).each do |inbox|
      next unless inbox.data["status"] == "promoted"

      path = inbox.data["investigation"]
      investigation = investigations[path]
      unless investigation
        error(inbox.path, "promoted Inbox points to missing Investigation")
        next
      end
      origin = investigation.data["origin"]
      error(inbox.path, "promoted Inbox does not match Investigation origin") unless origin == { "type" => "inbox", "reference" => inbox.path }
    end

    Array(by_kind[:investigation]).each do |investigation|
      data = investigation.data
      origin = data["origin"] || {}
      if origin["type"] == "inbox"
        inbox = inboxes[origin["reference"]]
        error(investigation.path, "missing origin Inbox") unless inbox
        error(investigation.path, "origin Inbox is not promoted back to this Investigation") if inbox && inbox.data["investigation"] != investigation.path
      elsif origin["type"] == "knowledge_note"
        note = notes[origin["reference"]]
        error(investigation.path, "missing origin Knowledge Note") unless note
        error(investigation.path, "origin Note lacks Investigation backlink") if note && !Array(note.data["investigations"]).include?(investigation.path)
      end

      Array(data["related_nodes"]).each { |id| error(investigation.path, "missing related node #{id}") unless nodes.key?(id) }
      target_id = data["promotion_target"]
      if target_id
        error(investigation.path, "promotion target duplicated in related_nodes") if Array(data["related_nodes"]).include?(target_id)
        target = notes[target_id]
        error(investigation.path, "promotion target lacks a Knowledge Note") unless target
        error(investigation.path, "promotion target Note lacks backlink") if target && !Array(target.data["investigations"]).include?(investigation.path)
      end

      required_domains = Set.new
      required_domains << node_domain(origin["reference"]) if origin["type"] == "knowledge_note"
      Array(data["related_nodes"]).each { |id| required_domains << node_domain(id) }
      required_domains << node_domain(target_id) if target_id
      Array(data["labs"]).each do |path|
        lab = labs[path]
        unless lab
          error(investigation.path, "missing Lab #{path}")
          next
        end
        error(investigation.path, "Lab #{path} does not point back to owner") unless lab.data["investigation"] == investigation.path
        Array(lab.data["related_nodes"]).each { |id| required_domains << node_domain(id) }
        if %w[closed abandoned].include?(data["status"]) && %w[planned running].include?(lab.data["status"])
          error(investigation.path, "terminal Investigation owns active Lab #{path}")
        end
      end
      actual_domains = Array(data["domains"]).to_set
      required_domains.compact.each do |domain|
        error(investigation.path, "domains omits #{domain}") unless actual_domains.include?(domain)
      end
      actual_domains.each { |domain| error(investigation.path, "domains names missing Domain #{domain}") unless domains.key?(domain) }
    end
  end

  def validate_labs(lab_artifacts, nodes, notes, investigations, domains)
    owners = Hash.new { |hash, key| hash[key] = [] }
    investigations.each_value do |investigation|
      Array(investigation.data["labs"]).each { |path| owners[path] << investigation.path }
    end
    Array(lab_artifacts).each do |lab|
      Array(lab.data["related_nodes"]).each do |id|
        error(lab.path, "missing related node #{id}") unless nodes.key?(id)
        note = notes[id]
        error(lab.path, "related Note #{id} lacks Lab backlink") if note && !Array(note.data["labs"]).include?(lab.path)
      end
      owner = lab.data["investigation"]
      if owner
        error(lab.path, "missing owner Investigation #{owner}") unless investigations.key?(owner)
        error(lab.path, "owner Investigation does not list Lab") unless owners[lab.path].include?(owner)
      elsif owners[lab.path].any?
        error(lab.path, "Investigation lists Lab whose owner is null")
      else
        related_notes = Array(lab.data["related_nodes"]).map { |id| notes[id] }.compact
        error(lab.path, "standalone Lab has no managing Knowledge Note") if related_notes.empty?
        if %w[planned running].include?(lab.data["status"])
          active_note = related_notes.any? do |note|
            domain = domains[note.data["domain"]]
            domain && domain.data["status"] == "active" && %w[draft reviewed published].include?(note.data["maturity"])
          end
          error(lab.path, "active standalone Lab has no Active Knowledge Note owner") unless active_note
        end
      end
      error(lab.path, "Lab is owned by multiple Investigations") if owners[lab.path].uniq.length > 1
    end
  end

  def validate_note_links(note_artifacts, investigations, labs)
    Array(note_artifacts).each do |note|
      id = note.data["id"]
      Array(note.data["investigations"]).each do |path|
        investigation = investigations[path]
        unless investigation
          error(note.path, "missing Investigation #{path}")
          next
        end
        origin = investigation.data["origin"]
        target = investigation.data["promotion_target"]
        unless (origin["type"] == "knowledge_note" && origin["reference"] == id) || target == id
          error(note.path, "Investigation #{path} is neither origin nor promotion backlink")
        end
      end
      Array(note.data["labs"]).each do |path|
        lab = labs[path]
        unless lab
          error(note.path, "missing Lab #{path}")
          next
        end
        error(note.path, "Lab #{path} lacks related_nodes backlink") unless Array(lab.data["related_nodes"]).include?(id)
      end
    end
  end

  def validate_archived_domains(by_kind, domains, notes, investigations, labs)
    domains.each do |id, domain|
      next unless domain.data["status"] == "archived"

      Array(by_kind[:roadmap]).select { |roadmap| roadmap.data["domain"] == id }.each do |roadmap|
        error(domain.path, "archived Domain has active Roadmap #{roadmap.data['id']}") if roadmap.data["status"] == "active"
      end
      notes.each_value do |note|
        next unless note.data["domain"] == id
        error(domain.path, "archived Domain has unfinished non-archived Note #{note.data['id']}") if %w[draft reviewed].include?(note.data["maturity"])
      end
      investigations.each_value do |investigation|
        origin = investigation.data["origin"]
        if investigation.data["status"] == "active" && origin["type"] == "knowledge_note" && node_domain(origin["reference"]) == id
          error(domain.path, "archived Domain has active Investigation from its Note")
        end
        target = investigation.data["promotion_target"]
        error(domain.path, "archived Domain node is a promotion target") if target && node_domain(target) == id
      end
      labs.each_value do |lab|
        tied = Array(lab.data["related_nodes"]).any? { |node| node_domain(node) == id }
        error(domain.path, "archived Domain has active related Lab #{lab.data['id']}") if tied && %w[planned running].include?(lab.data["status"])
      end
    end
  end

  def validate_updated_at(by_kind)
    candidates = by_kind.values.flatten.select { |artifact| artifact.data.key?("updated_at") }
    baseline = @baseline
    candidates.each do |artifact|
      created = parse_date(artifact.data["created_at"])
      updated = parse_date(artifact.data["updated_at"])
      error(artifact.path, "updated_at precedes created_at") if created && updated && updated < created
      error(artifact.path, "updated_at is later than the current calendar date") if updated && updated > Date.today
      next unless baseline

      previous = previous_artifact(artifact)
      unless previous
        observed = @view.observed_modification_date(artifact.path)
        if observed && updated && updated < observed
          error(artifact.path, "updated_at predates observed content modification date #{observed}")
        elsif observed.nil?
          warning(artifact.path, "modification date unavailable; updated_at freshness was not verified")
        end
        next
      end

      previous_updated = parse_date(previous.data["updated_at"])
      error(artifact.path, "updated_at moved backwards from Formal Baseline") if previous_updated && updated && updated < previous_updated
      current_without_date = artifact.data.reject { |key, _| key == "updated_at" }
      previous_without_date = previous.data.reject { |key, _| key == "updated_at" }
      content_changed = current_without_date != previous_without_date || artifact.body != previous.body
      observed = @view.observed_modification_date(artifact.path)
      if content_changed
        if observed && updated && updated < observed
          error(artifact.path, "updated_at predates observed content modification date #{observed}")
        elsif observed.nil?
          warning(artifact.path, "modification date unavailable; updated_at freshness was not verified")
        elsif artifact.data["updated_at"] == previous.data["updated_at"] && updated != observed
          error(artifact.path, "content changed from Formal Baseline without updating updated_at")
        end
      end
    end
  end

  def validate_terminal_transitions(by_kind)
    return if @view.mode == :head

    by_kind.values.flatten.each do |artifact|
      previous = previous_artifact(artifact)
      next unless previous

      case artifact.kind
      when :roadmap
        if %w[completed archived].include?(previous.data["status"]) && artifact.data["status"] != previous.data["status"]
          error(artifact.path, "terminal Roadmap was reopened or changed to another status")
        end
        previous_items = roadmap_items(previous.data)
        current_items = roadmap_items(artifact.data)
        previous_items.each do |node, status|
          next unless %w[completed skipped].include?(status)
          migrated_node = @migrations.fetch(node, node)
          error(artifact.path, "terminal item #{node} was removed or restored") unless current_items[migrated_node] == status
        end
      when :inbox
        if %w[promoted closed].include?(previous.data["status"]) && artifact.data["status"] != previous.data["status"]
          error(artifact.path, "terminal Inbox Item was reopened")
        end
      when :investigation
        if %w[closed abandoned].include?(previous.data["status"]) && artifact.data["status"] != previous.data["status"]
          error(artifact.path, "terminal Investigation was reopened")
        end
      when :lab
        if %w[completed invalid abandoned].include?(previous.data["status"]) && artifact.data["status"] != previous.data["status"]
          error(artifact.path, "terminal Lab was restored to another state")
        end
      when :knowledge_note
        if previous.data["maturity"] == "superseded" && artifact.data["maturity"] != "superseded"
          error(artifact.path, "terminal superseded Note changed maturity")
        end
      end
    end
  end

  def roadmap_items(data)
    Array(data["phases"]).flat_map { |phase| Array(phase["items"]) }
                          .to_h { |item| [item["node"], item["status"]] }
  end

  def parse_from_view(view, path)
    raw = view.read(path)
    yaml, body = if path.end_with?(".md")
                   match = raw.match(/\A---\s*\n(.*?)\n---\s*\n/m)
                   return nil unless match

                   [match[1], raw[match.end(0)..] || ""]
                 else
                   [raw, ""]
                 end
    data = Psych.safe_load(yaml, permitted_classes: [], permitted_symbols: [], aliases: false)
    return nil unless data.is_a?(Hash)

    Artifact.new(path: path, data: data, body: body, kind: nil)
  rescue Psych::Exception
    nil
  end

  def previous_artifact(artifact)
    return nil unless @baseline
    return parse_from_view(@baseline, artifact.path) if @baseline.exist?(artifact.path)

    current_id = artifact.data["id"]
    previous_id = @reverse_migrations[current_id]
    if previous_id
      match = baseline_artifacts(artifact.kind).find { |candidate| candidate.data["id"] == previous_id }
      return match if match
    end

    current_domain = artifact.data["domain"] || (artifact.kind == :domain && artifact.data["id"])
    previous_domain = @reverse_migrations[current_domain]
    return nil unless previous_domain && artifact.path.start_with?("domains/#{current_domain}/")

    previous_path = artifact.path.sub(%r{\Adomains/#{Regexp.escape(current_domain)}/}, "domains/#{previous_domain}/")
    parse_from_view(@baseline, previous_path) if @baseline.exist?(previous_path)
  end

  def baseline_artifacts(kind)
    @baseline_artifacts[kind] ||= @baseline.files(INSTANCE_PATTERNS.fetch(kind)).each_with_object([]) do |path, artifacts|
      artifact = parse_from_view(@baseline, path)
      next unless artifact

      artifact.kind = kind
      artifacts << artifact
    end
  end

  def validate_markdown_links
    @view.files("**/*.md").each do |path|
      markdown_targets(@view.read(path), path).each { |target| validate_markdown_target(path, target) }
    end
  end

  def markdown_targets(markdown, path)
    normalized = markdown.gsub(/(!?\[[^\]\n]*\]\()\s*<([^>\n]+)>(?=\s*(?:["']|\)))/) do
      "#{Regexp.last_match(1)}#{Regexp.last_match(2).gsub(" ", "%20")}"
    end
    document = RDoc::Markdown.parse(normalized)
    options = RDoc::Options.new
    options.pipe = true
    html = RDoc::Markup::ToHtml.new(options).convert(document)
    html.scan(/\b(?:href|src)="([^"]+)"/).flatten.map { |target| CGI.unescapeHTML(target) }.uniq
  rescue StandardError => e
    error(path, "cannot parse Markdown links: #{e.message}")
    []
  end

  def validate_markdown_target(source_path, target)
    return if target.match?(%r{\A(?:[a-z][a-z0-9+.-]*:|//)}i)

    destination, fragment = target.split("#", 2)
    relative = URI::DEFAULT_PARSER.unescape(destination.to_s.split("?", 2).first)
    resolved = if relative.empty?
                 source_path
               else
                 Pathname(File.join(File.dirname(source_path), relative)).cleanpath.to_s
               end
    unless @view.exist?(resolved)
      error(source_path, "broken Markdown link #{target}")
      return
    end
    return if fragment.nil? || fragment.empty? || !resolved.end_with?(".md")

    decoded_fragment = URI::DEFAULT_PARSER.unescape(fragment)
    unless markdown_anchor_ids(@view.read(resolved)).include?(decoded_fragment)
      error(source_path, "broken Markdown anchor #{target}")
    end
  rescue URI::Error => e
    error(source_path, "invalid Markdown link #{target}: #{e.message}")
  end

  def markdown_anchor_ids(markdown)
    document = RDoc::Markdown.parse(markdown)
    counts = Hash.new(0)
    heading_ids = document.parts.each_with_object([]) do |part, ids|
      next unless part.is_a?(RDoc::Markup::Heading)

      base = github_heading_slug(part.text)
      count = counts[base]
      counts[base] += 1
      ids << (count.zero? ? base : "#{base}-#{count}")
    end
    explicit_ids = markdown.scan(/<(?:a|[a-z][a-z0-9-]*)\b[^>]*\bid=["']([^"']+)["'][^>]*>/i).flatten
    (heading_ids + explicit_ids).to_set
  end

  def github_heading_slug(text)
    CGI.unescapeHTML(text.to_s.gsub(/<[^>]*>/, "").gsub(/[`*_~]/, ""))
       .downcase
       .gsub(/[^\p{L}\p{N}\s_-]/u, "")
       .strip
       .gsub(/\s/, "-")
  end

  def parse_date(value)
    Date.iso8601(value)
  rescue Date::Error, TypeError
    nil
  end

  def node_domain(node_id)
    node_id.to_s.split(".", 2).first unless node_id.nil?
  end
end

if $PROGRAM_NAME == __FILE__
  mode = :worktree
  migrations = {}
  arguments = ARGV.dup
  until arguments.empty?
    argument = arguments.shift
    case argument
    when "--index"
      mode = :index
    when "--head"
      mode = :head
    when "--migration"
      mapping = arguments.shift
      unless mapping&.include?("=")
        warn "--migration requires an exact old=new stable-ID mapping"
        exit 2
      end
      old_id, new_id = mapping.split("=", 2)
      if old_id.empty? || new_id.empty? || old_id == new_id || migrations.key?(old_id) || migrations.value?(new_id)
        warn "invalid or non-bijective migration mapping: #{mapping}"
        exit 2
      end
      migrations[old_id] = new_id
    else
      warn "usage: ruby #{File.basename(__FILE__)} [--index|--head] [--migration old=new ...]"
      exit 2
    end
  end
  if mode == :head && migrations.any?
    warn "--migration cannot be used with --head"
    exit 2
  end

  view = RepositoryView.new(mode)
  validator = RepositoryValidator.new(view, migrations: migrations)
  errors = validator.run
  validator.warnings.uniq.sort.each { |message| warn "manual check: #{message}" }
  if errors.empty?
    puts "automated repository validation passed (#{mode})"
    puts "manual gates remain: exact-snapshot acceptance, author decisions, substantive-content review, Evidence quality, and transition history not present in Git"
    exit 0
  end

  warn "repository validation failed (#{mode}):"
  errors.uniq.sort.each { |message| warn "- #{message}" }
  exit 1
end
