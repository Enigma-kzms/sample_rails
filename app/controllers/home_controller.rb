class HomeController < ApplicationController
  def top
    p 'passed top'
    p session[:user_id] if session[:user_id]
    if session[:user_id]
      user = User.find_by_email(session[:user_id])
      @name = user.name
      p @name
    end
  end

  def signup
    @confirm = params if params[:name] && params[:email] && params[:password] && params[:password_confirm]
    @name = nil unless @confirm
    @email = nil unless @confirm
    @name = params[:df_name] if params[:df_name]
    @email = params[:df_email] if params[:df_email]
    return redirect_to home_signup_path(:df_name => @confirm[:name], :df_email => @confirm[:email]), :alert => '名前を入力してください' if params[:name] == "" && @confirm
    return redirect_to home_signup_path(:df_name => @confirm[:name], :df_email => @confirm[:email]), :alert => 'メールアドレスを入力して下さい' if params[:email] == "" && @confirm
    return redirect_to home_signup_path(:df_name => @confirm[:name], :df_email => @confirm[:email]), :alert => 'パスワードを入力して下さい' if params[:password] == "" && @confirm
    redirect_to home_signup_path(:df_name => @confirm[:name], :df_email => @confirm[:email]), :alert => '確認用パスワードが一致しません' if params[:password] != params[:password_confirm] && @confirm
  end

  def create
    user = User.new(signup_params)
    user.name = params[:name]
    user.email = params[:email]
    user.password_digest = params[:password]
    return redirect_to root_path, :notice => '登録しました' if user.save
    redirect_to root_path, :notice => '登録に失敗しました'
  end

  def login
    if params[:email] && params[:password]
      return redirect_to home_login_path, :alert => 'メールアドレスを入力してください' if params[:email] == "" && params[:password] == ""
      return redirect_to home_login_path, :alert => 'パスワードを入力してください' if params[:email] && params[:password] == ""
      return redirect_to home_login_path, :alert => 'メールアドレスを入力してください' if params[:email] == "" && params[:password]
      if User.find_by(email: params[:email], password_digest: params[:password])
        user = User.find_by(email: params[:email])
        session[:user_id] = user.email
        redirect_to root_path, :notice => 'ログインできました'
      else
        redirect_to home_login_path, :alert => 'メールアドレスまたはパスワードが一致しません'
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, :notice => 'ログアウトしました'
  end

  private
  def signup_params
    params.permit(:name, :email, :password_digest)
  end
end
