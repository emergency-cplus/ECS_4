class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  def index
    if params[:tag].present?
      # タグに基づいてアイテムをフィルタリング
      @items = current_user.items.tagged_with(params[:tag]).order(created_at: :desc).page(params[:page]).per(10)
    else
      # すべてのアイテムを表示
      @items = current_user.items.order(created_at: :desc).page(params[:page]).per(10)
    end
  end

  def show; end

  def new
    @item = Item.new
  end

  def edit; end

  def create
    @item = current_user.items.new(item_params)
    # nil チェックを追加
    tag_list = item_params[:tag_list].presence || ''
    # タグリストを3つまでに制限して処理
    @item.tag_list = item_params[:tag_list].split(',').map(&:strip).uniq.first(3)
    existing_item = Item.find_by(item_url: @item.item_url)

    if existing_item
      redirect_to item_path(existing_item), alert: 'すでにアイテムとして保存されています'
    elsif @item.save
      flash[:success] = 'アイテムを作成しました'
      redirect_to items_url
    else
      flash.now[:danger] = 'アイテムを作成できませんでした'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # nil チェックを追加
    tag_list = item_params[:tag_list].presence || ''
    # タグリストを3つまでに制限して処理
    @item.tag_list = item_params[:tag_list].split(',').map(&:strip).uniq.first(3)

    if @item.update(item_params)
      flash[:success] = 'アイテムを更新しました'
      redirect_to item_url(@item)
    else
      flash.now[:danger] = 'アイテムを更新できませんでした'
      render :edit, status: :unprocessable_entity
    end
  end
  

  def destroy
    @item.destroy
    flash[:success] = 'アイテムを削除しました'
    redirect_to items_url
  end

  private

  def item_params
    params.require(:item).permit(:title, :description, :item_url, :tag_list)
  end

  def set_item
    @item = current_user.items.find_by(id: params[:id])
    unless @item
      redirect_to items_path, alert: '指定されたアイテムにはアクセスできません。'
    end
  end

end
