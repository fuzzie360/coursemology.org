class DuplicateController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:manage]

  def manage
    @missions = @course.missions
    @trainings = @course.trainings
    lecturer_courses = current_user.user_courses.lecturer
    @my_courses = lecturer_courses.map { |uc| uc.course }
  end

  def duplicate_assignments
    require 'duplication'
    dest_course = Course.find(params[:dest_course])
    puts dest_course.to_json
    authorize! :manage, dest_course
    authorize! :duplicate, Course

    training_ids = params[:trainings] || []
    training_ids.each do |id|
      training = @course.trainings.find(id)
      if training
        Duplication.duplicate_asm(current_user, training, @course, dest_course)
      end
    end

    mission_ids = params[:missions] || []
    mission_ids.each do |id|
      mission = @course.missions.find(id)
      if mission
        Duplication.duplicate_asm(current_user, mission, @course, dest_course)
      end
    end

    respond_to do |format|
      format.html { redirect_to course_path(dest_course),
                    notice: "The specified assignments have been duplicated." }
    end
  end

  def duplicate_course
    require 'duplication'
    authorize! :duplicate, @course
    authorize! :create, Course
    clone = Duplication.duplicate_course(current_user, @course)
    respond_to do |format|
      format.html { redirect_to edit_course_path(clone),
                    notice: "The course '#{@course.title}' has been duplicated." }
    end
  end
end
