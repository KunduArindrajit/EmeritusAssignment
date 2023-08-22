require 'byebug'
class User < ApplicationRecord
    has_many :enrollments_as_student, foreign_key: :user_id, class_name: "Enrollment"
    has_many :enrollments_as_teacher, foreign_key: :teacher_id, class_name: "Enrollment"

    has_many :teachers, through: :enrollments_as_student, source: :teacher
    has_many :students, through: :enrollments_as_teacher, source: :user

    has_many :programs, through: :enrollments_as_student, foreign_key: :enrollment_id, class_name: "Program"

    validate :kind_updatable?, :if => :kind_changed?

    enum kind: [:student, :teacher, :student_and_teacher]

    # scope :favorites, -> { includes(:enrollments_as_teacher).where(enrollments_as_teacher: {user_id: user.id, favorite: true}).distinct}

    # def favorites
    #     User.where(id: enrollments_as_student.where(favorite: true).pluck(:teacher_id))
    # end

    def self.classmates(user)
        User.includes(:enrollments_as_student).where(enrollments_as_student: {program_id: user.programs}).where.not(id: user.id).distinct
    end

    private
    def kind_updatable?
        errors.add(:kind, 'Kind can not be student because is teaching in at least one program') if kind == "student" && enrollments_as_teacher.any?
        errors.add(:kind, 'Kind can not be teacher because is studying in at least one program') if kind == "teacher" && enrollments_as_student.any?
    end
end
