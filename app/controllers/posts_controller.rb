# frozen_string_literal: true

class PostsController < ApplicationController
  layout 'scaffold'

  before_action :authenticate_user!, except: %i[show index]

  before_action :set_post, only: %i[

    show

    edit

    update

    destroy

    like

    unlike

    dislike

    undislike

  ]

  # before_action :user, only: %i[show]

  before_action :posts, only: %i[show create]

  respond_to :js, :html, :json

  # GET /posts

  def index
    @posts = if params[:search].present?

               Post.perform_search(params[:search])

             else

               Post.all.order(created_at: :desc).page(params[:page])

             end

    @posts_size = Post.all.size
  end

  # GET /posts/1

  def show
    @user = @post.user
  end

  # GET /posts/new

  def new
    @post = Post.new
  end

  # GET /posts/1/edit

  def edit; end

  # POST /posts

  def create
    @post = current_user.posts.create!(post_params)

    respond_to do |format|
      if @post.save

        format.js {}

        format.html do
          redirect_to root_path, notice: 'Votre publication a bien été ajoutée.'
        end

        format.json { render :show, status: :created, location: @post }

      else

        format.html do
          flash[:danger] = "Votre publication n'a pas été ajoutée : #{

          @post.errors.messages

        }"

          render :new
        end

        format.json { render json: @post.errors, status: :unprocessable_entity }

        format.js { render layout: false, content_type: 'text/javascript' }

      end
    end
  end

  # PATCH/PUT /posts/1

  def update
    if @post.update(post_params)

      redirect_to @post, notice: 'Post was successfully updated.'

    else

      render :edit

    end
  end

  # DELETE /posts/1

  def destroy
    @post.destroy

    respond_to do |format|
      format.html do
        redirect_to :back,
                    notice: 'Votre publication a bien été supprimé.'
      end

      format.json { head :no_content }

      format.js   { render layout: false }
    end
  end

  def like
    if @post.user != current_user

      @post.liked_by current_user

      if @post.save!

        flash.now[:notice] = "You have successfuly upvoted #{@post.title}"

      else

        flash.now[:error] = "Could not upvote this #{@post.title}"

      end

    else

      flash.now[:error] = 'You cannot upvote your own post.'

    end
  end

  def unlike
    @post.unliked_by current_user if @post.user != current_user
  end

  def dislike
    if @post.user != current_user

      @post.disliked_by current_user

      if @post.save!

        flash.now[:notice] = "You have successfuly downvoted #{@post.title}"

      else

        flash.now[:error] = "Could not downvote this #{@post.title}"

      end

    else

      flash.now[:error] = 'You cannot downvote your own post.'

    end
  end

  def undislike
    @post.undisliked_by current_user if @post.user != current_user
  end

  private

  # Use callbacks to share common setup or constraints between actions.

  def posts
    @posts = Post.all.order(created_at: :desc).page(params[:page])
  end

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.

  def post_params
    params.require(:post).permit(
      :title,
      :description,
      :created_at,
      :updated_at,
      :file,
      :tag_list
    )
  end
end
