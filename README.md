# 20180626_Day12

### scaffold의 form_for

- 지금까지 2주정도의 시간동안 사용했던 `form_tag` 는 모델의 객체와 관계없이 우리가 사용하고자 하는 형태대로 많은 것을 가능하게 했다. 이에 반해 `form_for` 는 모델의 객체와 관련을 두어 모델의 컬럼과 관련있는 `params` 만 받을 수 있게 설정할 수 있다.

```erb
<%= form_for(@post) do |f| %>
	<%= f.text_field :title %>
	<%= f.text_area :contents %>
	<%= f.submit %>
<% end %>
```

- 위의 코드는 `Post` 모델에 `title` 과 `contents` 컬럼이 있는 경우 해당 컬럼에 해당하는 파라미터를 생성할 수 있다.
- 기본의 파라미터의 형태가 `params: {title: "title", contents: "contents"} ` 였다면, `form_for` 에서 만들어지는 파라미어터의 형태는 `params: {post: {title: "title", contents: "contents"}}` 의 형태가 된다.
- `form_for` 는 굉장히 많은 부분과 연관되어 있다. 라우팅, 모델, 컨트롤러에 연관되어 있는데, 모델 부분은 이전에 이야기 했던 것처럼 특정 모델의 객체가 가지고 있는 컬럼에 대한 input만 만들 수 있다.

> ```
> form_for(record, options = {}, &block)
> ```
>
> Creates a form that allows the user to create or update the attributes of a specific model object.
>
> 출처: `form_for` 와 관련된 [API-Dock](https://apidock.com/rails/ActionView/Helpers/FormHelper/form_for)

- `form_for` 에 어떤 객체를 넘기느냐에 따라서 각기 다른 `action` 이 설정된다.

```erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

의 코드는

```erb
<%= form_for @post, as: :post, url: post_path(@post), method: :patch, html: { class: "edit_post", id: "edit_post_45" } do |f| %>
  ...
<% end %>
```

와 같은 코드로 변환된다.

- 위의 경우는 `@post` 가 이미 table에 저장되어 있는 경우에 해당한다. 이미 저장되어 있던 값일 경우에 기존의 값을 수정하는 코드로 변환된다. 반대로 `@post` 가 `Post.new` 에 의해 새로 만들어진 빈 껍데이길 경우 다음과 같은 코드로 변환된다.

```erb
<%= form_for(Post.new) do |f| %>
  ...
<% end %>
```

의 코드는

```erb
<%= form_for @post, as: :post, url: posts_path, html: { class: "new_post", id: "new_post" } do |f| %>
  ...
<% end %>
```

와 같은 코드로 변환된다.

- 우리가 scaffold 명령어를 통해 만들어진 컨트롤러를 확인할 때 `new` 액션에도 `@post = Post.new` 라는 코드가 들어가있는 것을 확인할 수 있었는데, 실제로 `_form` 을 통해 `new` 와  `edit` 에서 사용하는 form을 같은 파일로 사용하기 위해 사용됐다.



### Route prefix

- 스캐폴드로 만들어진 내용을 차근차근 살펴보다보면 `link_to` 의 url이 들어갈 부분에  `new_post_path`나 `edit_post_path` 와 같은 변수 형태가 들어가있는 것을 확인할 수 있다. 이것은 레일즈에서 제공하는 view helper의 일종으로 루비 코드로 url을 만들어 낼 수 있다.

```command
$ rake routes
          Prefix Verb   URI Pattern                          Controller#Action
		   posts GET    /posts(.:format)                     posts#index
                 POST   /posts(.:format)                     posts#create
        new_post GET    /posts/new(.:format)                 posts#new
       edit_post GET    /posts/:id/edit(.:format)            posts#edit
            post GET    /posts/:id(.:format)                 posts#show
                 PATCH  /posts/:id(.:format)                 posts#update
                 PUT    /posts/:id(.:format)                 posts#update
                 DELETE /posts/:id(.:format)                 posts#destroy
```

- Prefix 부분에 앞에서 언급했던 `new_post_path` 나 `edit_post_path` 부분과 유사한 모습의 코드를 볼 수 있다. 바로 이  Prefix 부분에 `_path` 혹은 `_url` 을 붙여주면 해당 uri나 url을 만들 수 있다.

```erb
<%= link_to 'new', new_post_path %>

<a href="/posts/new">new</a>
```

- 이러한 형태로 대체할 수 있다.



### Comment(댓글기능)

*붙여넣기*



### M:N

- 우리는 유저와 작성글의 관계, 작성글과 댓글의 관계 등을 통해 1대 다(1:N)관계에 대해서 알아보았다. 하지만 1대 다 관계만으로는 구현할 수 없는 부분이 많이 있다. 대표적으로 특정 유저가 카페에 가입한다고 했을 때, 유저는 여러개의 카페에 가입할 수 있지만 카페도 여러명의 유저를 회원으로 만들 수 있다. 이러한 관계를 M:N 혹은 다대다 라고 한다.
- 다대다 관계는 반드시 중간에 Join Table이 있어야 한다. 이 Join Table은 M쪽의 id와 N쪽의 id 를 각각 컬럼으로 가지고 있으면서 양쪽의 관계가 성립하게 한다.

```command
$ rails g model user user_name:string
$ rails g model daum title:string
$ rails g model membership user_id:integer daum_id:integer
```

*db/migrate/create_memberships*

```ruby
class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :daum_id
      t.timestamps
    end
  end
end
```

> Rails 공식 가이드에서는 다음과 같은 이미지로 표현하고 있다.
>
> ![m:n](http://guides.rubyonrails.org/images/has_many_through.png)

- 일단 이미지의 형태만 기억하자

*app/models/membership.rb*

```ruby
class Membership < ApplicationRecord
    belongs_to :user
    belongs_to :daum
end
```

*app/models/user.rb*

```ruby
class User < ApplicationRecord
    has_many :memberships
end
```

*app/models/daum.rb*

```ruby
class Daum < ApplicationRecord
    has_many :memberships
end
```

- 코드가 완성되면 왠지 느낌은 양쪽에 연결되었으니 정상적으로 동작할 것같다. 먼저 우리가 원하는 형태를 살펴보자

```text
1번 유저는 1,2,3번 카페에 가입했다.
2번 유저는 2,3번 카페에 가입했다.
3번 유저는 1,3번 카페에 가입했다.

1번 카페에는 1,3번 유저가 있다.
2번 카페에는 1,2번 유저가 있다.
3번 카페에는 1,2,3번 유저가 있다.
```

- 그리고 이를 의사코드로 변환하면 다음과 같다.

```text
1번 유저는 1,2,3번 카페에 가입했다.
u1.daums # => [1번카페, 2번카페, 3번카페]
...

1번 카페에는 1,3번 유저가 있다.
d1.users # => [1번유저, 3번유저]
```

- 하지만 아마도 지금의 코드는 위와같이 동작하지 않을 것이다. 이를 동작시키기 위해서 '여러개 가지고 있는 membership들을 통해 daum 혹은 user를 여러개 가진다' 라는 의미의 코드를 추가해야한다.

```ruby
class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships
end
```

```ruby
class User < ApplicationRecord
    has_many :memberships
    has_many :daums, through: :memberships
end
```

- 이렇게 추가하면 `u1.daums` 와 `c1.users` 와 같은 코드도 동작하게 된다.
- 추후에 더 사용하면서 익혀보도록 하자.