class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :edit, :update, :destroy]
  skip_before_action :authorize, only: [:create, :update, :destroy]
  
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_cart
  # GET /carts
  # GET /carts.json
  def index
    @carts = Cart.all
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
    unless @cart.id == session[:cart_id]
      # user tried to access somebody else's cart
      respond_to do |format|
        format.html { redirect_to store_url, notice: 'Invalid cart'}
        format.json {head :no_content}
      end
    end
  end

  # GET /carts/new
  def new
    @cart = Cart.new
  end

  # GET /carts/1/edit
  def edit
    @cart = Cart.find_by(id: session[:cart_id])
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new(cart_params)

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'Cart was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cart }
      else
        format.html { render action: 'new' }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carts/1
  # PATCH/PUT /carts/1.json
  def update
    respond_to do |format|
      if @cart.update(cart_params)
        format.html { redirect_to @cart, notice: 'Cart was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    if @cart.id == session[:cart_id]
      @cart.destroy
      session[:cart_id] = nil
      respond_to do |format|
        format.html { redirect_to store_url }
        format.js
        format.json { head :no_content }
      end
    else
      # user tried to delete somebody else's cart
      respond_to do |format|
        format.html { redirect_to store_url, notice: 'Invalid Cart ID, cart not deleted'}
        format.json {head :no_content}
      end
    end
  end

private
  
  # redirect to store_url if somehow user tries to access an invalid cart id
  def invalid_cart(e)
    logger.error "Attempt to access invalid cart #{params[:id]}"
    ErrorNotifier.error_occurred(e).deliver
    redirect_to store_url, notice: 'Invalid cart'
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_cart
    @cart = Cart.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cart_params
    params[:cart]
  end
end
