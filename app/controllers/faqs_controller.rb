# frozen_string_literal: true

class FaqsController < ApplicationController
  # Layout

  layout 'scaffold'

  # Find FAQ

  before_action :set_faq, only: %i[show edit update destroy]

  # GET /faqs
  def index
    @faqs = Faq.all
  end

  # GET /faqs/1
  def show; end

  # GET /faqs/new
  def new
    @faq = Faq.new
  end

  # GET /faqs/1/edit
  def edit; end

  # POST /faqs
  def create
    @faq = Faq.new(faq_params)

    if @faq.save
      redirect_to @faq, notice: 'Faq was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /faqs/1
  def update
    if @faq.update(faq_params)
      redirect_to @faq, notice: 'Faq was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /faqs/1
  def destroy
    @faq.destroy
    redirect_to faqs_url, notice: 'Faq was successfully destroyed.'
  end

  private

  # Set FAQ
  def set_faq
    @faq = Faq.find(params[:id])
  end

  # FAQ parameters
  def faq_params
    params.fetch(:faq, {})
  end
end
