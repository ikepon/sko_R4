# coding utf-8

class LessonsController < ApplicationController

  add_breadcrumb 'Home', '/'

  before_filter :authenticate_user!, :except => [:index, :home, :grade, :tangen, :show, :new_lesson,:ranking, :category, :agreement, :privacy]

  protect_from_forgery

  before_filter :set_search

  def set_search
  @search = Lesson.search(params[:q])
  end

  def index

    add_breadcrumb 'レッスン検索結果', '/lessons'

    #検索結果表示
    @search = Lesson.search(params[:q])
    @search_lessons = @search.result.page(params[:page]).per(10)

  end

  def home

    # @grade1_units = Lesson.where(:grade => '1').select('unit_name').group('lessons.unit_name')
    # @grade1_units_all = Lesson.where(:grade => '1').select('unit_name, unit_item_name').group('lessons.unit_item_name')
    # @grade2_units = Lesson.where(:grade => '2').select('unit_name').group('lessons.unit_name')
    # @grade2_units_all = Lesson.where(:grade => '2').select('unit_name, unit_item_name').group('lessons.unit_item_name')
    # @grade3_units = Lesson.where(:grade => '3').select('unit_name').group('lessons.unit_name')
    # @grade3_units_all = Lesson.where(:grade => '3').select('unit_name, unit_item_name').group('lessons.unit_item_name')

    @grade1_units = Lesson.where(:grade => '1').select('unit_name').group('lessons.unit_name')
    @grade1_units_all = Lesson.where(:grade => '1').select('unit_name, unit_item_name').group('lessons.unit_item_name')
    @grade2_units = Lesson.where(:grade => '2').select('unit_name').group('lessons.unit_name')
    @grade2_units_all = Lesson.where(:grade => '2').select('unit_name, unit_item_name').group('lessons.unit_item_name')
    @grade3_units = Lesson.where(:grade => '3').select('unit_name').group('lessons.unit_name')
    @grade3_units_all = Lesson.where(:grade => '3').select('unit_name, unit_item_name').group('lessons.unit_item_name')

  end

  def grade

    @grade = request.path_info[6,1]
    @grade_jp = "中学" + @grade + "年生"

    add_breadcrumb @grade_jp

    @title = @grade_jp + '数学の単元一覧'
    @description = @grade_jp + 'で勉強する数学の単元一覧です。'

    @grade_units = Lesson.where(:grade => @grade).select('unit_name').group('unit_name')
    @grade_units_all = Lesson.where(:grade => @grade).select('unit_name, unit_item_name').group('unit_item_name')

  end

  def tangen

    @grade_unit_item_name = params[:type]

    @grade = request.path_info[6,1]
    @grade_jp = "中学" + @grade + "年生"

    add_breadcrumb @grade_jp, '/grade' + @grade + '/index'
    add_breadcrumb @grade_unit_item_name

    @grade_lessons = Lesson.where("unit_item_name = ? and grade = ?", @grade_unit_item_name, @grade).select('id, title, summary, exercise, point')

    @title = @grade_jp + '数学の' + @grade_unit_item_name
    @description = @grade_jp + 'で勉強する数学の単元「' + @grade_unit_item_name + '」のレッスン一覧です。'

  end

  def show
    @grade_unit_item_name = params[:type]
    @lesson = params[:lesson]

    @grade = request.path_info[6,1]
    @grade_jp = "中学" + @grade + "年生"

    add_breadcrumb @grade_jp, '/grade' + @grade + '/index'
    add_breadcrumb @grade_unit_item_name,'/grade' + @grade + '/' + @grade_unit_item_name

    @lesson_info = Lesson.where(:id => @lesson).select('id, title, summary, time, explanation, exercise, exercise_answer, point, number')

    add_breadcrumb @lesson_info[0].title

    @title = @grade_jp + '数学の' + @lesson_info[0].title
    @description = @grade_jp + 'で勉強する数学の単元「' + @grade_unit_item_name + '」の「' + @lesson_info[0].title + '」内容です。'

    #pre, next
    @grade_lesson_ids = Lesson.where("unit_item_name = ? and grade = ?", @grade_unit_item_name, @grade).order("number").pluck('id')

    @lesson_index = @grade_lesson_ids.index(@lesson.to_i)

    if @lesson_index == 0
      @pre_lesson = "#"
      @pre_lesson_class = " disabled"

      @next_lesson_info = Lesson.where("id = ?", @grade_lesson_ids[@lesson_index.to_i + 1]).select('grade, unit_item_name, id')
      @next_lesson = "/grade" + @grade.to_s + "/" + @next_lesson_info[0].unit_item_name + "/" + @next_lesson_info[0].id.to_s
      @next_lesson_class = ""

    elsif @lesson_index == @grade_lesson_ids.count - 1
      @pre_lesson_info = Lesson.where("id = ?", @grade_lesson_ids[@lesson_index.to_i - 1]).select('grade, unit_item_name, id')
      @pre_lesson = "/grade" + @grade.to_s + "/" + @pre_lesson_info[0].unit_item_name + "/" + @pre_lesson_info[0].id.to_s
      @pre_lesson_class = ""

      @next_lesson = "#"
      @next_lesson_class =  " disabled"

    else
      @pre_lesson_info = Lesson.where("id = ?", @grade_lesson_ids[@lesson_index.to_i - 1]).select('grade, unit_item_name, id')
      @pre_lesson = "/grade" + @grade.to_s + "/" + @pre_lesson_info[0].unit_item_name + "/" + @pre_lesson_info[0].id.to_s
      @pre_lesson_class = ""

      @next_lesson_info = Lesson.where("id = ?", @grade_lesson_ids[@lesson_index.to_i + 1]).select('grade, unit_item_name, id')
      @next_lesson = "/grade" + @grade.to_s + "/" + @next_lesson_info[0].unit_item_name + "/" + @next_lesson_info[0].id.to_s
      @next_lesson_class = ""

    end

    if user_signed_in?
      @user_id = current_user.id

      if @user_id.present?
        @learning = Learning.where("user_id = ? and lesson_id = ?", @user_id, @lesson).first_or_create do |l|
          l.user_id = @user_id
          l.lesson_id = @lesson
          l.status = 'false'
          l.check = 0
        end
      end
    end
  end

  def new_lesson

    add_breadcrumb '新着レッスン'

    @title = '新着レッスン一覧'
    @description = '新しく追加したレッスン一覧を紹介しています。'

    @new_lessons_main = Lesson.select('grade, unit_name, unit_item_name, created_at').order('created_at DESC')

  end

  def ranking
    add_breadcrumb '人気レッスン'

    @title = '人気レッスン一覧'
    @description = 'ユーザに利用されているレッスンのランキングを紹介しています。'

    popular_lessons_id = Learning.group('lesson_id').order('count_lesson_id DESC').count('lesson_id').keys
    @popular_lessons_main = Lesson.find(popular_lessons_id)

  end

  def category

    add_breadcrumb 'レッスンカテゴリー'

    @title = 'レッスンカテゴリ一覧'
    @description = '各学年、各単元をカテゴリーに分けて紹介しています。'

    @categories = Lesson.select('category_name').group('category_name')
    @category_lessons_all = Lesson.select('grade, category_name, unit_name, unit_item_name').group('unit_item_name')

  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def agreement

    add_breadcrumb '利用規約'

    @title = '利用規約'
    @description = '当サイトの利用にあたっての規約ページとなります。'

    @rule = Agreement.all(:order => "created_at DESC", :limit => 1)

    render 'rule'

  end

  def privacy

    add_breadcrumb 'プライバシーポリシー'

    @title = 'プライバシーポリシー'
    @description = '当サイトで取得した個人情報の取り扱いに関するページになります。'

    @rule = Privacy.all(:order => "created_at DESC", :limit => 1)

    render 'rule'

  end
end
