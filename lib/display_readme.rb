# frozen_string_literal: true

# Hook class for displaying README content in repository views
# Integrates with Redmine's view system to inject README content
class DisplayReadme < Redmine::Hook::ViewListener
  MAX_README_BYTES = 1_048_576
  MARKDOWN_EXTENSIONS = %w[.markdown .mdown .mkdn .md .mkd .mdwn .mdtxt .mdtext .text].freeze

  def view_repositories_show_contextual(context)
    return unless readme_enabled?(context)

    readme_data = extract_readme_data(context)
    return unless readme_data

    render_readme_partial(context, readme_data)
  end

  private

  def readme_enabled?(context)
    EnabledModule.exists?(project_id: context[:project].id, name: 'readme_at_repository') &&
      RarProjectSetting.exists?(project_id: context[:project].id)
  end

  def extract_readme_data(context)
    repo_info = get_repository_info(context)
    return unless repo_info[:repo]

    readme_content = get_readme_content(repo_info)
    return unless readme_content

    {
      html: format_readme_content(readme_content[:file], readme_content[:text]),
      settings: RarProjectSetting.find_by(project_id: context[:project].id)
    }
  end

  def get_repository_info(context)
    path = context[:request].params['path'] || ''
    rev = context[:request].params['rev'].presence
    repo_id = context[:request].params['repository_id']
    repo = find_repository(context[:project], repo_id)

    { repo: repo, path: path, rev: rev }
  end

  def get_readme_content(repo_info)
    repo = repo_info[:repo]
    return unless repo

    entry = repo.entry(repo_info[:path])
    return unless entry&.is_dir?

    readme_file = find_readme_file(repo, repo_info[:path], repo_info[:rev])
    return unless readme_file

    raw_text = repo.cat(readme_file.path, repo_info[:rev])
    return unless valid_readme_raw?(raw_text)

    { file: readme_file, text: raw_text }
  end

  def valid_readme_raw?(raw_text)
    raw_text &&
      raw_text.bytesize <= MAX_README_BYTES &&
      !raw_text.include?("\x00")
  end

  def render_readme_partial(context, readme_data)
    context[:controller].send(:render_to_string, {
                                partial: 'repository/readme',
                                locals: {
                                  html: readme_data[:html],
                                  position: readme_data[:settings][:position],
                                  show: readme_data[:settings][:show]
                                }
                              })
  end

  def find_repository(project, repo_id)
    if repo_id
      project.repositories.find { |r| r.identifier == repo_id }
    else
      project.repositories.find(&:is_default)
    end
  end

  def find_readme_file(repo, path, rev)
    entries = repo.entries(path, rev)
    return unless entries

    entries.find { |entry| entry.name =~ /README((\.).*)?/i }
  end

  def format_readme_content(file, raw_text)
    safe_text = ensure_utf8(raw_text)
    formatter_name = determine_formatter(file)
    if formatter_name.present?
      formatter = Redmine::WikiFormatting.formatter_for(formatter_name).new(safe_text)
      formatter.to_html
    else
      # Plain text fallback (escape to avoid injection)
      ERB::Util.html_escape(safe_text)
    end
  end

  # Normalize to UTF-8, replacing invalid/undefined bytes.
  def ensure_utf8(text)
    return '' unless text

    str = text.dup
    # If git adapter returns ASCII-8BIT, first assume it is UTF-8 bytes.
    str.force_encoding(Encoding::UTF_8) if str.encoding == Encoding::ASCII_8BIT
    str = str.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '?') unless str.valid_encoding?
    str
  end

  def determine_formatter(file)
    return '' unless MARKDOWN_EXTENSIONS.include?(File.extname(file.path))

    Redmine::WikiFormatting.format_names.find { |name| name =~ /common_mark/i } ||
      Redmine::WikiFormatting.format_names.find { |name| name =~ /markdown/i } ||
      ''
  end
end
