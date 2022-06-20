class CommentController < ApplicationController
  require "http"
  skip_before_action :verify_authenticity_token
  before_action :prepare

  def index
    return render :create if params[:comment] == ""
    @comment = Comment.where(user_id: @id)
    return render :show if params[:format].nil? && params[:comment].nil?
    if params[:format] == 'attack'
      return redirect_to comment_index_path, :alert => 'コメントを最低ひとつは作成してください' if @comment == []
      forms = []
      @payload.each do |payload|
        forms.push([payload.memo, payload.thread_num])
      end
      @forms = forms
      render :index
    end
  end

  def show
  end

  def edit
    value = Comment.find(params[:id])
    @comment = value.text
    return flash.now[:alert] = '入力してください' if params[:commit] && params[:comment] == ""
    if params[:id] && params[:comment]
      comment = Comment.find(params[:id])
      comment.text = params[:comment]
      redirect_to comment_index_path if comment.update(text: comment.text)
    end
  end

  def create
    if params[:comment]
      return redirect_to comment_index_path(:comment => ""), :alert => '入力してください' if params[:comment] == ""
      param = params[:comment]
      comment = Comment.new(comment_params)
      comment.text = param
      comment.user_id = @id
      redirect_to comment_index_path if comment.save
    else
    end
  end

  def confirm
    return redirect_to comment_index_path(:format => 'attack') , :alert => '投稿コメントを選択してください' unless params[:check_box]
    return redirect_to comment_index_path unless params[:select] || params[:check_box] || params[:min]
    thread = Payload.find_by(thread_num: params[:select])
    @thread = thread.memo
    text = []
    params[:check_box].each do |checks|
      text.push(Comment.find(checks).text)
    end
    @text = text
    @min = params[:min]
  end

  def excute
    return redirect_to comment_index_path unless params[:thread] || params[:text] || params[:min]
    thread = Payload.find_by(memo: params[:thread])
    thread = thread.thread_num
    text = []
    name = '匿名'
    params[:text].each do |checks|
      text.push(checks)
    end
    min = params[:min]
    if text.size > 1
      text.each_with_index do |texts, index|
        # 荒らし防止のためドメインは割愛
        uri = "https://ここにドメイン/post_comment/?mode=execute&thread_no=" + thread.to_s + "&nickname=" + name.to_s + "+&comment=" + texts
        p uri
        response = HTTP.get(uri)
        puts "success!" if response.code == 200
        p min.to_s + '分間隔'
        count = index + 1
        p count.to_s + '回目'
        break if index + 1 == text.size
        sleep min.to_i * 60
      end
    else
      # 荒らし防止のためドメインは割愛
      uri = "https://ここにドメイン/post_comment/?mode=execute&thread_no=" + thread.to_s + "&nickname=" + name.to_s + "&comment=" + text[0].to_s
      p uri
      response = HTTP.get(uri)
      puts "success!" if response.code == 200
    end
    redirect_to comment_index_path, :notice => '投稿が終わりました'
  end

  def destroy
    p 'passed destroy'
    if params[:id]
      Comment.find(params[:id]).destroy
      redirect_to comment_index_path
    end
  end

  private
  def comment_params
    params.permit(:text)
  end

  protected
  def prepare
    return redirect_to root_path if session[:user_id].nil?
    @comment = Comment.all
    @payload = Payload.all
    user = User.find_by_email(session[:user_id])
    @name = user.name
    @id = user.id
  end
end
