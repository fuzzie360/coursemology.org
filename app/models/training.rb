class Training < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  # Assignments may have other assignment as requirement
  # Not implemented yet.
  include HasRequirement
  include ActivityObject
  include Assignment

  attr_accessible :course_id, :creator_id, :description, :exp, :max_grade, :open_at, :pos, :title, :bonus_exp, :bonus_cutoff, :publish, :t_type

  belongs_to :creator, class_name: "User"
  belongs_to :course

  has_many :mcqs, through: :asm_qns, source: :qn, source_type: "Mcq"
  has_many :coding_questions, through: :asm_qns, source: :qn, source_type: "CodingQuestion"
  has_many :training_submissions, dependent: :destroy
  has_many :files, as: :owner, class_name: "FileUpload", dependent: :destroy


  def update_grade
    self.max_grade = self.mcqs.sum(&:max_grade) + self.coding_questions.sum(&:max_grade)
    self.save
  end

  def get_path
     course_training_path(course, self)
  end

  def questions
    self.asm_qns.order(:pos).map {|q| q.qn}
  end

  def attach_files(files)
    files.each do |id|
      file = FileUpload.find(id)
      file.owner = self
      file.save
    end
  end

  def total_exp
    exp + bonus_exp.to_i
  end

  def coding_questions_before(pos)
    coding_questions.where("pos < ?", pos)
  end

  alias_method :sbms, :training_submissions
end
