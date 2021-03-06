Forem::SubscriptionMailer.class_eval do
  def new_topic(topic_id, subscriber_id)
    # only pass id to make it easier to send emails using resque
    @topic = Forem::Topic.find(topic_id)
    @user = Forem.user_class.find(subscriber_id)

    @forum = @topic.forum
    @course = Course.find(@forum.category.id)
    @post = @topic.posts.first
    mail(:to => @user.email, :subject => @course.title + ': ' + I18n.t('forem.topic.received_new_topic'), :content_type => "text/html")
  end
end