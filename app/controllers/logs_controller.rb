class LogsController < ApplicationController
  layout 'main'

  def api_logs
    query = ClientActivityHistory
    query = query.where(:action => params[:act]) if params[:act]
    query = query.where(:user_id => params[:user_id]) if params[:user_id]
    query = query.where(:user_type => params[:user_type]) if params[:user_type]
    query = query.where(:device_id => params[:device_id]) if params[:device_id]

    @logs = query.order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @logs }
    end
  end

  def show_api_logs

    query = ClientActivityHistory.where(:user_type => params[:type])
    query = query.where(:action => params[:act]) if params[:act]
    query = query.where(:user_id => params[:user_id]) if params[:user_id]
    query = query.where(:user_type => params[:user_type]) if params[:user_type]
    query = query.where(:device_id => params[:device_id]) if params[:device_id]

    @logs = query.order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @logs }
    end
  end

  def show_api_log
    @log = ClientActivityHistory::find params[:id]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @log }
    end
  end

  def destroy_api_logs
    @log = ClientActivityHistory.find(params[:id]) rescue nil
    @log.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  # GET /logs
  # GET /logs.json
  def index
    if params[:type]
      query = Log::where(:log_type => params[:type]).order('created_at DESC')
    else
      query = Log.order('created_at DESC')
    end
    @logs = query.paginate(:page => params[:page], :per_page => params[:per_page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @logs }
    end
  end

  # GET /logs/1
  # GET /logs/1.json
  def show
    @log = Log.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @log }
    end
  end

  # GET /logs/new
  # GET /logs/new.json
  def new
    @log = Log.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @log }
    end
  end

  # GET /logs/1/edit
  def edit
    @log = Log.find(params[:id])
  end

  # POST /logs
  # POST /logs.json
  def create
    @log = Log.new(params[:log])

    respond_to do |format|
      if @log.save
        format.html { redirect_to @log, notice: 'Log was successfully created.' }
        format.json { render json: @log, status: :created, location: @log }
      else
        format.html { render action: "new" }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /logs/1
  # PUT /logs/1.json
  def update
    @log = Log.find(params[:id])

    respond_to do |format|
      if @log.update_attributes(params[:log])
        format.html { redirect_to @log, notice: 'Log was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /logs/1
  # DELETE /logs/1.json
  def destroy
    @log = Log.find(params[:id])
    @log.destroy

    respond_to do |format|
      format.html { redirect_to logs_url }
      format.json { head :no_content }
    end
  end

  def clear
    ActiveRecord::Base.connection.execute('TRUNCATE TABLE logs')
    redirect_to '/logs'
  end

  def clear_api_logs
    ActiveRecord::Base.connection.execute('TRUNCATE TABLE client_activity_histories')
    redirect_to '/api_logs'
  end
end
