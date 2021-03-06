# coding utf-8

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :sidebar, :footer

  # before_filter :configure_permitted_parameters, if: :devise_controller?

  protected
  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.for(:sign_up) << :name
  # end

  def sidebar
    # 新着レッスン、人気レッスン
    @new_lessons = Lesson.select('grade, unit_name, unit_item_name, created_at').order('created_at DESC').limit(3)
    popular_lessons_ids = Learning.group('lesson_id').order('count_lesson_id DESC').count('lesson_id').keys
    @popular_lessons = Lesson.find(popular_lessons_ids)

    @users_total = User.all.count()
    @users_grade = User.group('grade').count('grade')

    @complete_lessons = Learning.where(:status => true).count()
    @check_lessons = Learning.where(:check => true).count()
    if @users_total != 0
      @average_comp = @complete_lessons / @users_total
      @average_check = @check_lessons / @users_total
    else
      @average_comp = 0
      @average_check = 0
    end

    if user_signed_in?
      @user_id = current_user.id

      @user_info = User.where(:id => @user_id)

      @user_learning_ids = Learning.where("user_id = ? and status = ?", @user_id, true).pluck('lesson_id')

      @sum_time = 0
      @times = Lesson.where(:id => @user_learning_ids).select('time')

      if @times.present?
        @times.each do |t|
          @sum_time += t.time.min * 60 + t.time.sec
        end
      end
      @user_total_time = Time.now.midnight.advance(:seconds => @sum_time).strftime('%T')

      @user_ranking = []
      Learning.where('status = ?', true).joins(:lesson).group(:user).sum(:time).each{ | user, total |
        @user_ranking += [user.id, total.to_i]
      }
      @user_ranking = Hash[*@user_ranking].sort_by{|k,v| v }
      @user_ranking_hash = Hash[@user_ranking].keys
      @user_rank = (@user_ranking_hash.index(@user_id).to_i + 1)
    end

  end

  def footer
    @footer_grade1 = Lesson.where(:grade => '1').select('unit_name').group('unit_name')
    @footer_grade2 = Lesson.where(:grade => '2').select('unit_name').group('unit_name')
    @footer_grade3 = Lesson.where(:grade => '3').select('unit_name').group('unit_name')
    @footer_categories = Lesson.select('category_name').group('category_name')

  end
end
