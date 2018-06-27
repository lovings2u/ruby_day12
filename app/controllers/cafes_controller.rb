class CafesController < ApplicationController
    # 전체 카페 목록보여주는 페이지
    # -> 로그인 하지 않았을 때: 전체 카페 목록
    # -> 로그인 했을때: 유저가 가입한 카페 목록
    def index
        if user_signed_in?
            @cafes = current_user.daums
        else
            @cafes = Daum.all
        end
    end
    
    # 카페 내용물을 보여주는 페이지(이 카페의 게시물)
    def show
        @cafe = Daum.find(params[:id])
    end
    
    # 카페를 개설하는 페이지
    def new
        @cafe = Daum.new
    end
    # 카페를 실제로 개설하는 로직
    def create
        @cafe = Daum.new(daum_params)
        @cafe.master_name = current_user.user_name
        if @cafe.save
            redirect_to cafe_path(@cafe), flash: {success: "카페가 개설되었습니다."}
        else
            redirect_to :back, flash: {danger: "카페 개설에 실패했습니다."}
        end
    end
    # 카페 정보 수정하는 페이지
    # 카페 정보를 실제로 수정하는 로직
    
    private
    def daum_params
        params.require(:daum).permit(:title, :description)
        # :params => {:daum => {:title => "...", :description => "..."}}
    end
end
