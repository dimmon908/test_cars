class CardController < ApplicationController
  respond_to :js, :html

  def new
    build_resource({})
    render action: :new, :layout => false
  end

  def create
    build_resource(params[resource_name])

    if Card::where(:card_number => resource.card_number, :user_id => current_user.partner_id).any?
      resource.errors[:card_number] << 'Already exist card with such number for your user'
      render json: {:status => :error, :message => resource.errors.messages.to_json}
      return
    end

    if resource.save
      if Payment::Type::net_terms?(current_user) && !current_user.approve
        current_user.payment = :CC
        current_user.card_id = resource.id
        current_user.save :validate => false
      end

      render json: {:status => :ok, :id => resource.id}
    else
      render json: {:status => :error, :message => resource.errors.messages.to_json}
    end
  end

  def edit
    self.resource = resource_class.find params[:id]
    render action: :edit, :layout => false
  end

  def index
    render action: :index, :layout => false
  end

  def update

    log_exception Exception.new('card update')
    begin
      card = resource_class.find params[:id]

      resource = params[resource_name]
      render json: {:status => :error, :message => 'Invalid request data'} and return if card.nil? || resource.nil?

      user = nil
      user = User.find params[:user_id] if params[:user_id]
      user = current_user unless user

      if Card::where('card_number = ? and user_id = ? and id != ?', resource['card_number'], user.partner_id, params[:id]).any?
        resource.errors[:card_number] << 'Already exist card with such number for your user'
        render json: {:status => :error, :message => resource.errors.messages.to_json}
        return
      end

      if card.update_attributes(resource)
        query = User::where('card_id = ? AND (partner_id IS NULL OR id = partner_id)', card.id)
        query.each {|_user| _user.send_change_cc } if query.any?

        render json: {:status => :ok, :id => card.id}
      else
        render json: {:status => :error, :message => card.errors.messages.to_json}
      end
    rescue Exception => e
      render json: {:status => :error, :message => e.to_s}
    end
  end

  def show

  end

  def delete
    card = resource_class::find params[:id] rescue nil
    render json: {:status => :error, :message => 'Not exist such card id'} and return unless card
    card.destroy
    render json: {:status => :ok}
  end

  # @return [Card]
  def resource
    instance_variable_get(:"@#{resource_name}")
  end
  # @param [Card] new_resource
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  private
  def build_resource(hash=nil)
    self.resource = resource_class.new(hash || {})
  end

  def resource_name
    'card'
  end
  def resource_class
    Card
  end

  helper_method :resource, :resource_class, :resource_name
end
