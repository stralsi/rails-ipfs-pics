require 'rest-client'

class PicsController < ApplicationController
  before_action :set_pic, only: [:show]

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

  # POST /pics
  # POST /pics.json
  def create
    begin
      ipfs_hash = post_to_ipfs upload_params.tempfile

      thumb_file_name = 'thumb_'+upload_params.original_filename
      create_thumbnail thumb_file_name, upload_params.read
      thumb_hash = post_to_ipfs thumb_file_name

      @pic = Pic.new ({:name=>upload_params.original_filename,
                      :ipfs_hash=>ipfs_hash,
                      :thumbnail_ipfs_hash => thumb_hash})

    rescue Exception => e
      Rails.logger.error e
    ensure
      File.delete thumb_file_name if File.exists? thumb_file_name
    end

    respond_to do |format|
      if !@pic.nil? and @pic.save
        format.html { redirect_to @pic, notice: 'Pic was successfully created.' }
        format.json { render :show, status: :created, location: @pic }
      else
        format.html { render :new }
        format.json { render json: @pic.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pic
      @pic = Pic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def upload_params
      params.require(:uploaded_file)
    end

    def post_to_ipfs(file_path)
      result_hash = ''
      File.open file_path do |f|
        response = RestClient.post 'http://127.0.0.1:5001/api/v0/add', :myfile => f
        hashResponse = JSON.parse response

        result_hash = hashResponse["Hash"]
      end

      return result_hash
    end

    def create_thumbnail(thumb_file_path, file_content)
      image = MiniMagick::Image.read file_content, '.jpg'
      image.resize "500x500"
      image.write thumb_file_path
    end
end
