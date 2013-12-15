class Comic < ActiveRecord::Base

  attr_accessible :visible, :chapter, :name, :episode, :dependent_mission_id, :next_mission_id

  scope :published, where(:visible => true)

  belongs_to :course
  belongs_to :dependent_mission, class_name: "Mission", foreign_key: "dependent_mission_id"
  belongs_to :next_mission, class_name: "Mission", foreign_key: "next_mission_id"

  has_many :comic_pages, dependent: :destroy

  def attach_files(files)
    last_page = self.comic_pages.order('page DESC').first
    page_no = last_page ? last_page.page : 0
    sorted = files.sort_by {|key, id| FileUpload.find_by_id(id).display_filename}
    sorted.each do |key, id|
      # Create a material record
      comic_page = ComicPage.create(comic: self)

      # Associate the file upload with the record
      file = FileUpload.find_by_id(id)
      if not(file)
        next
      end
      page_no += 1
      comic_page.attach(file)
      comic_page.page = page_no
      comic_page.save
    end
  end

  def can_view?(curr_user_course)
    if dependent_mission
      dependency = dependent_mission.can_start?(curr_user_course).first
    else
      dependency = true
    end
    visible && dependency
  end

end