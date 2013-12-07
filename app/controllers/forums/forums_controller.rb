class Forums::ForumsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, except: [:destroy]

  before_filter :load_forum, except: [:index]
  load_and_authorize_resource :forum, except: [:index]

  def index
    @forums = @course.forums
  end

  def show
    @topics = @forum.topics.accessible_by(current_ability)
    @topics = @topics.page(params[:page]).per(@course.forum_paging_pref.prefer_value.to_i)
  end

  def new

  end

  def create
    @forum.assign_attributes(params[:forum_forum])
    @forum.course = @course
    @forum.save

    respond_to do |format|
      format.html { redirect_to course_forum_path(@course, @forum),
                                notice: 'The forum was successfully created.' }
    end
  end

private
  def load_forum
    @forum = ForumForum.find_using_slug(params[:id])
    if %w(new create).include?(params[:action])
      @forum = ForumForum.new
      @forum.assign_attributes(params[:forum])
    end
  end
end
