class Objective
  # запрос
  def locked?
    locked_by.present? &&
    [LOCK_STATUSES[:uploading], LOCK_STATUSES[:locked]].include?(lock_status)
  end

  # команда
  def release_lock
    assign_attributes(
      :locked_by => nil,
      :locked_on_name => nil,
      :locked_on_id => nil,
      :lock_status => LOCK_STATUSES[:unlocked]
    )
  end

  # команда
  def release_lock!
    release_lock
    save
  end
end


class Book
  # запрос
  def ebook?
    file.present?
  end

  # запрос
  def path_prefix
    Digest::MD5.hexdigest((id || title).to_s)[0..1]
  end

  # команда
  def file=(data)
    unless data.blank?
      fn = data.original_filename.gsub('/', '_')
      target_dir = Rails.root.join('public', 'system', path_prefix)
      FileUtils.mkdir_p(target_dir) unless File.exists?(target_dir)
      FileUtils.mv(data.tempfile.path, File.join(target_dir, fn))
      File.chmod(0644, File.join(target_dir, fn))
      self[:file] = fn
    end
  end

  # команда
  def delete_file!
    self[:file] = nil
    save
  end

  # запрос
  def file_url
    "/system/#{path_prefix}/#{URI.escape(file)}"
  end
end
