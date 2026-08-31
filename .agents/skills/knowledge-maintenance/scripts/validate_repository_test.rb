# frozen_string_literal: true

require "minitest/autorun"
require_relative "validate_repository"

class MemoryView
  attr_reader :mode

  def initialize(files = {}, mode: :worktree, modification_dates: {})
    @files = files
    @mode = mode
    @modification_dates = modification_dates
  end

  def files(pattern)
    @files.keys.select { |path| File.fnmatch?(pattern, path, File::FNM_PATHNAME | File::FNM_EXTGLOB) }.sort
  end

  def exist?(path)
    @files.key?(path) || @files.keys.any? { |file| file.start_with?("#{path}/") }
  end

  def read(path)
    @files.fetch(path)
  end

  def observed_modification_date(path)
    @modification_dates[path]
  end
end

class RepositoryValidationTest < Minitest::Test
  def setup
    @note_schema = JSON.parse(File.read(File.join(ROOT, "schemas/knowledge-note-frontmatter.schema.json")))
    @roadmap_schema = JSON.parse(File.read(File.join(ROOT, "schemas/roadmap.schema.json")))
    @note = Psych.safe_load(frontmatter(File.join(ROOT, "templates/knowledge-note.md")), aliases: false)
    @roadmap = Psych.safe_load(File.read(File.join(ROOT, "templates/roadmap.yaml")), aliases: false)
  end

  def test_reviewed_note_requires_current_review_metadata
    reviewed = @note.merge(
      "maturity" => "reviewed",
      "ai_reviewed" => true,
      "reviewed_at" => "2026-08-31"
    )
    assert_empty validate(reviewed, @note_schema)

    substantively_changed = reviewed.merge("maturity" => "draft")
    refute_empty validate(substantively_changed, @note_schema)

    reset = substantively_changed.merge(
      "ai_reviewed" => false,
      "author_confirmed" => false,
      "reviewed_at" => nil,
      "published_at" => nil
    )
    assert_empty validate(reset, @note_schema)
  end

  def test_planned_and_in_progress_items_may_become_skipped
    planned = @roadmap.dig("phases", 0, "items", 0)
    planned["status"] = "skipped"
    planned["completed_at"] = nil
    assert_empty validate(@roadmap, @roadmap_schema)
  end

  def test_completed_item_requires_completion_date
    item = @roadmap.dig("phases", 0, "items", 0)
    item["status"] = "completed"
    refute_empty validate(@roadmap, @roadmap_schema)

    item["completed_at"] = "2026-08-31"
    assert_empty validate(@roadmap, @roadmap_schema)
  end

  def test_superseded_chain_may_end_at_revision_but_not_initial_learning
    source = note_artifact("example-domain.old", "superseded", nil, "example-domain.new")
    revision = note_artifact("example-domain.new", "draft", "revision", nil)
    assert_empty replacement_errors(source, revision)

    initial = note_artifact("example-domain.new", "draft", "initial_learning", nil)
    refute_empty replacement_errors(source, initial)

    archived = note_artifact("example-domain.new", "archived", nil, nil)
    refute_empty replacement_errors(source, archived)
  end

  def test_contextual_related_node_does_not_require_note_backlink
    note = link_note("example-domain.context")
    investigation = Artifact.new(
      path: "investigations/context.md",
      data: {
        "origin" => { "type" => "inbox", "reference" => "inbox/2026-08-31-context.md" },
        "promotion_target" => nil,
        "related_nodes" => [note.data["id"]]
      },
      body: "",
      kind: :investigation
    )
    assert_empty note_link_errors(note, investigations: { investigation.path => investigation }, labs: {})
  end

  def test_note_and_lab_links_must_be_reciprocal
    note = link_note("example-domain.example-node")
    lab = Artifact.new(
      path: "labs/example/README.md",
      data: { "related_nodes" => [], "investigation" => nil },
      body: "",
      kind: :lab
    )
    note.data["labs"] = [lab.path]
    refute_empty note_link_errors(note, investigations: {}, labs: { lab.path => lab })

    lab.data["related_nodes"] = [note.data["id"]]
    assert_empty note_link_errors(note, investigations: {}, labs: { lab.path => lab })
  end

  def test_new_artifact_may_be_created_and_updated_on_different_days
    artifact = Artifact.new(
      path: "domains/example-domain/knowledge/new-note.md",
      data: { "created_at" => "2026-08-30", "updated_at" => "2026-08-31" },
      body: "new content",
      kind: :knowledge_note
    )
    validator = RepositoryValidator.new(MemoryView.new, baseline: MemoryView.new({}, mode: :head))
    validator.send(:validate_updated_at, { knowledge_note: [artifact] })
    assert_empty validator.instance_variable_get(:@errors)
  end

  def test_updated_at_must_not_predate_observed_content_modification
    path = "domains/example-domain/knowledge/example-node.md"
    baseline = MemoryView.new(
      { path => markdown_artifact("example-domain.example-node", "2026-08-28", "old") },
      mode: :head
    )
    current = MemoryView.new({}, modification_dates: { path => Date.new(2026, 8, 31) })
    artifact = Artifact.new(
      path: path,
      data: { "id" => "example-domain.example-node", "created_at" => "2026-08-28", "updated_at" => "2026-08-29" },
      body: "new",
      kind: :knowledge_note
    )
    validator = RepositoryValidator.new(current, baseline: baseline)
    validator.send(:validate_updated_at, { knowledge_note: [artifact] })
    assert_includes validator.instance_variable_get(:@errors).join("\n"), "predates observed content modification"
  end

  def test_same_day_change_does_not_require_updated_at_to_change_again
    path = "domains/example-domain/knowledge/example-node.md"
    baseline = MemoryView.new(
      { path => markdown_artifact("example-domain.example-node", "2026-08-31", "old") },
      mode: :head
    )
    current_view = MemoryView.new({}, modification_dates: { path => Date.new(2026, 8, 31) })
    artifact = Artifact.new(
      path: path,
      data: { "id" => "example-domain.example-node", "created_at" => "2026-08-28", "updated_at" => "2026-08-31" },
      body: "new",
      kind: :knowledge_note
    )
    validator = RepositoryValidator.new(current_view, baseline: baseline)
    validator.send(:validate_updated_at, { knowledge_note: [artifact] })
    assert_empty validator.instance_variable_get(:@errors)
  end

  def test_migration_mapping_preserves_terminal_roadmap_item_history
    path = "domains/example-domain/roadmaps/example.yaml"
    previous = roadmap_artifact(path, "example-domain.old", "completed")
    current = roadmap_artifact(path, "example-domain.new", "completed")
    baseline = MemoryView.new({ path => Psych.dump(previous.data) }, mode: :head)

    without_mapping = RepositoryValidator.new(MemoryView.new, baseline: baseline)
    without_mapping.send(:validate_terminal_transitions, { roadmap: [current] })
    refute_empty without_mapping.instance_variable_get(:@errors)

    with_mapping = RepositoryValidator.new(
      MemoryView.new,
      baseline: baseline,
      migrations: { "example-domain.old" => "example-domain.new" }
    )
    with_mapping.send(:validate_terminal_transitions, { roadmap: [current] })
    assert_empty with_mapping.instance_variable_get(:@errors)
  end

  def test_migration_mapping_associates_renamed_artifact_with_baseline_history
    old_path = "domains/example-domain/knowledge/old.md"
    new_path = "domains/example-domain/knowledge/new.md"
    baseline = MemoryView.new(
      { old_path => markdown_artifact("example-domain.old", "2026-08-30", "old content") },
      mode: :head
    )
    current = Artifact.new(
      path: new_path,
      data: { "id" => "example-domain.new", "created_at" => "2026-08-28", "updated_at" => "2026-08-30" },
      body: "new content\n",
      kind: :knowledge_note
    )
    validator = RepositoryValidator.new(
      MemoryView.new({}, modification_dates: { new_path => Date.new(2026, 8, 31) }),
      baseline: baseline,
      migrations: { "example-domain.old" => "example-domain.new" }
    )
    validator.send(:validate_updated_at, { knowledge_note: [current] })
    assert_includes validator.instance_variable_get(:@errors).join("\n"), "predates observed content modification"
  end

  def test_schema_version_semantics_ignore_documentation_but_include_compatible_constraint_changes
    validator = RepositoryValidator.new(MemoryView.new)
    old_schema = { "description" => "old", "properties" => { "status" => { "enum" => ["a"] } } }
    documented = { "description" => "new", "properties" => { "status" => { "enum" => ["a"] } } }
    expanded = { "description" => "new", "properties" => { "status" => { "enum" => %w[a b] } } }
    reordered = {
      "description" => "new",
      "properties" => { "status" => { "enum" => ["a"] } },
      "required" => %w[status id]
    }
    reordered_again = reordered.merge("required" => %w[id status])

    old_semantics = validator.send(:validation_semantics, old_schema)
    assert_equal old_semantics, validator.send(:validation_semantics, documented)
    refute_equal old_semantics, validator.send(:validation_semantics, expanded)
    assert_equal validator.send(:validation_semantics, reordered), validator.send(:validation_semantics, reordered_again)
  end

  def test_duplicate_roadmap_ids_and_missing_graph_are_reported
    domain = Artifact.new(
      path: "domains/example-domain/domain.yaml",
      data: { "id" => "example-domain", "status" => "active" },
      body: "",
      kind: :domain
    )
    map = Artifact.new(
      path: "domains/example-domain/map.yaml",
      data: { "domain" => "example-domain", "nodes" => [{ "id" => "example-domain.node", "parent" => nil }] },
      body: "",
      kind: :map
    )
    roadmaps = %w[a b].map do |slug|
      Artifact.new(
        path: "domains/example-domain/roadmaps/#{slug}.yaml",
        data: {
          "id" => "example-domain.same",
          "domain" => "example-domain",
          "status" => "active",
          "phases" => [{ "id" => "phase", "items" => [{ "node" => "example-domain.node", "status" => "planned" }] }]
        },
        body: "",
        kind: :roadmap
      )
    end
    validator = RepositoryValidator.new(MemoryView.new, baseline: MemoryView.new({}, mode: :head))
    validator.instance_variable_set(:@artifacts, [domain, map, *roadmaps])
    validator.send(:validate_cross_file_rules)
    errors = validator.instance_variable_get(:@errors).join("\n")
    assert_includes errors, "duplicate id example-domain.same"
    assert_includes errors, "missing graph.yaml"
  end

  def test_missing_templates_are_reported
    validator = RepositoryValidator.new(MemoryView.new)
    validator.send(:validate_templates)
    errors = validator.instance_variable_get(:@errors)
    assert_equal RepositoryValidator::TEMPLATE_FILES.length, errors.length
    assert errors.all? { |message| message.include?("missing required template") }
  end

  def test_standalone_lab_requires_a_managing_active_note
    lab = Artifact.new(
      path: "labs/orphan/README.md",
      data: { "status" => "planned", "investigation" => nil, "related_nodes" => [] },
      body: "",
      kind: :lab
    )
    validator = RepositoryValidator.new(MemoryView.new)
    validator.send(:validate_labs, [lab], {}, {}, {}, {})
    errors = validator.instance_variable_get(:@errors).join("\n")
    assert_includes errors, "standalone Lab has no managing Knowledge Note"
    assert_includes errors, "active standalone Lab has no Active Knowledge Note owner"
  end

  def test_markdown_link_validation_handles_titles_references_code_and_anchors
    files = {
      "docs/source.md" => <<~MARKDOWN,
        [inline](target.md "title")
        [reference][target]
        [space](<file name.md>)

        [target]: target.md#target-heading

        ```markdown
        [example only](missing.md)
        ```
      MARKDOWN
      "docs/target.md" => "# Target Heading\n",
      "docs/file name.md" => "# File\n"
    }
    validator = RepositoryValidator.new(MemoryView.new(files))
    validator.send(:validate_markdown_links)
    assert_empty validator.instance_variable_get(:@errors)
  end

  def test_markdown_link_validation_reports_missing_anchor
    files = {
      "source.md" => "[broken](target.md#missing)\n",
      "target.md" => "# Present\n"
    }
    validator = RepositoryValidator.new(MemoryView.new(files))
    validator.send(:validate_markdown_links)
    assert_includes validator.instance_variable_get(:@errors).join("\n"), "broken Markdown anchor"
  end

  private

  def frontmatter(path)
    File.read(path).match(/\A---\s*\n(.*?)\n---\s*\n/m).captures.first
  end

  def validate(instance, schema)
    SchemaValidator.new(schema).validate(instance)
  end

  def note_artifact(id, maturity, cycle, superseded_by)
    Artifact.new(
      path: "domains/example-domain/knowledge/#{id.split('.', 2).last}.md",
      data: {
        "id" => id,
        "maturity" => maturity,
        "knowledge_cycle" => cycle,
        "superseded_by" => superseded_by
      },
      body: "",
      kind: :knowledge_note
    )
  end

  def markdown_artifact(id, updated_at, body)
    <<~MARKDOWN
      ---
      id: #{id}
      created_at: "2026-08-28"
      updated_at: "#{updated_at}"
      ---
      #{body}
    MARKDOWN
  end

  def roadmap_artifact(path, node, status)
    Artifact.new(
      path: path,
      data: {
        "id" => "example-domain.roadmap",
        "domain" => "example-domain",
        "status" => "active",
        "phases" => [{ "id" => "phase", "items" => [{ "node" => node, "status" => status }] }]
      },
      body: "",
      kind: :roadmap
    )
  end

  def replacement_errors(*notes)
    validator = RepositoryValidator.new(RepositoryView.new(:worktree))
    validator.send(:validate_replacement_chains, notes.to_h { |note| [note.data["id"], note] })
    validator.instance_variable_get(:@errors)
  end

  def link_note(id)
    Artifact.new(
      path: "domains/example-domain/knowledge/#{id.split('.', 2).last}.md",
      data: { "id" => id, "investigations" => [], "labs" => [] },
      body: "",
      kind: :knowledge_note
    )
  end

  def note_link_errors(note, investigations:, labs:)
    validator = RepositoryValidator.new(RepositoryView.new(:worktree))
    validator.send(:validate_note_links, [note], investigations, labs)
    validator.instance_variable_get(:@errors)
  end
end
