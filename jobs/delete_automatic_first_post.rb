module Jobs
  class DeleteAutomaticFirstPost < Jobs::Base
    def execute(args)
      return unless SiteSetting.automatic_first_post_plugin_enabled

      post = Post.find(args[:post_id])
      return if post.blank? || post.trashed?

      PostDestroyer.new(Discourse.system_user, post).destroy
    end
  end
end
