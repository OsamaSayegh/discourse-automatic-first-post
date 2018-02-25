# name: discourse-automatic-first-post
# about: A plugin to create an automatic post on every new topic
# version: 0.2
# authors: Osama Sayegh
# url: https://github.com/OsamaSayegh/discourse-automatic-first-post

after_initialize do
  load File.expand_path('../jobs/delete_automatic_first_post.rb', __FILE__)

  DiscourseEvent.on(:topic_created) do |topic, _, _user|
    if SiteSetting.automatic_first_post_plugin_enabled && topic.archetype == Archetype.default
      user = User.find_by(username: SiteSetting.automatic_first_post_owner.gsub(/@/, "")) || Discourse.system_user 

      post = PostCreator.create!(
        user,
        raw: I18n.t("automatic_first_post.post_content", username: user.username, name: user.name),
        topic_id: topic.id,
        skip_bot: true,
        skip_validations: true
      )

      Jobs.enqueue_at(
        SiteSetting.automatic_first_post_delete_after_mins.minutes.from_now,
        :delete_automatic_first_post,
        post_id: post.id
      )
    end
  end
end
