# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :deny_invalid_user, except: %i[index new show create]
  before_action :deny_not_secret_owner, except: %i[index new create]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    random_eyecatch = current_user.premium? ? params[:blog][:random_eyecatch] : false
    params.require(:blog).permit(:title, :content, :secret).merge(random_eyecatch: random_eyecatch)
  end

  def deny_invalid_user
    raise ActiveRecord::RecordNotFound if current_user != @blog.user
  end

  def deny_not_secret_owner
    raise ActiveRecord::RecordNotFound if not_secret_owner?
  end

  def not_secret_owner?
    @blog.secret? && current_user != @blog.user
  end
end
