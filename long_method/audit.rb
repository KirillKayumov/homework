class Audit
  def archive!
    self.status = 'archive'
    if save
      todos.destroy_all
      destroy_old_attachment_versions
      attached_documents.reload.each(&:unlock!)
      objectives.each(&:release_lock!)
      project_roles.includes(:relationship).each do |r|
        r.update_attributes(:name => 'reviewer')
      end
    end
  end
end


----------------------------------------------------------------------------------------


class Audit
  def archive!
    self.status = 'archive'
    update_related_resources_on_audit_archive if save
  end

  private

  def update_related_resources_on_audit_archive
    ActiveRecord::Base.transaction do
      destroy_resources_on_audit_archive
      unlock_resources_on_audit_archive
      update_project_roles_on_audit_archive
    end
  end

  def destroy_resources_on_audit_archive
    todos.destroy_all
    destroy_old_attachment_versions
  end

  def unlock_resources_on_audit_archive
    attached_documents.reload.each(&:unlock!)
    objectives.each(&:release_lock!)
  end

  def update_project_roles_on_audit_archive
    project_roles.includes(:relationship).each do |r|
      r.update_attributes(:name => 'reviewer')
    end
  end
end
