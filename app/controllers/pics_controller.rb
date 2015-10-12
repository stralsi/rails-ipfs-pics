require 'ipfs-api'
require 'rest-client'

class PicsController < ApplicationController
  before_action :set_pic, only: [:show, :edit, :update, :destroy]
  before_action :set_ipfs_conn

  # GET /pics
  # GET /pics.json
  def index
    @pics = Pic.all
  end

  # GET /pics/1
  # GET /pics/1.json
  def show
  end

  # GET /pics/new
  def new
    @pic = Pic.new
  end

  # GET /pics/1/edit
  def edit
  end

  # POST /pics
  # POST /pics.json
  def create

    file_name = pic_params.original_filename
    file_content = pic_params.read

    image = MiniMagick::Image.read file_content, '.jpg'
    image.resize "500x500"
    image.write file_name

    File.open file_name do |f|
      begin
        response = RestClient.post 'http://127.0.0.1:5001/api/v0/add', :myfile => f
        hashResponse = JSON.parse response

        @pic = Pic.new({name: file_name, ipfs_hash: hashResponse["Hash"]})
      rescue Exception => e
        Rails.logger.error e
      end
    end

    File.delete file_name



    # file_node = IPFS::Upload.file file_name do |fd|
    #   fd.write image.to_blob
    # end
    #
    # @ipfs_conn.add file_node do |node|
    #   @pic = Pic.new({name: node.name,ipfs_hash: node.hash}) if node.finished?
    # end

    respond_to do |format|
      if @pic.save
        format.html { redirect_to @pic, notice: 'Pic was successfully created.' }
        format.json { render :show, status: :created, location: @pic }
      else
        format.html { render :new }
        format.json { render json: @pic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pics/1
  # PATCH/PUT /pics/1.json
  def update
    respond_to do |format|
      if @pic.update(pic_params)
        format.html { redirect_to @pic, notice: 'Pic was successfully updated.' }
        format.json { render :show, status: :ok, location: @pic }
      else
        format.html { render :edit }
        format.json { render json: @pic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pics/1
  # DELETE /pics/1.json
  def destroy
    @pic.destroy
    respond_to do |format|
      format.html { redirect_to pics_url, notice: 'Pic was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pic
      @pic = Pic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pic_params
      params.require(:uploaded_file)
    end

    def set_ipfs_conn
      @ipfs_conn = IPFS::Connection.new
    end
end
