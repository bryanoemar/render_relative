module CommonHelper
  def render_relative(relative_path, *args)
    path_info = request.env['PATH_INFO']

    return relative_path if path_info.blank? || relative_path.blank?

    path_info.gsub!('./', '') if(path_info.starts_with?('./'))

    relative_path, last_part = remove_last_part(relative_path)

    current_path = resolve_current_path(path_info, relative_path)
    current_path = remove(Rails.root.to_s, current_path.to_s)

    if(!current_path.ends_with?('/'))
      current_path = current_path + '/'
    end

    current_path = current_path + last_part

    render current_path, *args
  end

  private
    def resolve_current_path(path_info, relative_path)
      resolved_path = Rails.root.join('app', 'views', path_info, relative_path)

      if directory_exists?(resolved_path)
        resolved_path = remove_path_parts(Rails.root.join('app', 'views'), resolved_path)

        return resolved_path
      end

      path_info, deleted_part = remove_last_part(path_info)
      resolve_current_path(path_info, relative_path)
    end

    def directory_exists?(path)
      File.directory?(path)
    end

    def remove_last_part(path_info)
      last_part = path_info.split("/").last

      return nil if last_part.nil?

      path_info = remove(last_part, path_info)
      return path_info, last_part
    end

    def remove(to_be_deleted, raw_string)
      raw_string.gsub(to_be_deleted, '')
    end

    def remove_path_parts(path, resolved_path)
      resolved_path.relative_path_from(Rails.root.join('app', 'views'))
    end
end
