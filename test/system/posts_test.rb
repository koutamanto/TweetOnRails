require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
  end

  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "投稿一覧"
  end

  test "should create post" do
    visit posts_url
    click_on "新規投稿"

    fill_in "タイトル", with: @post.title
    fill_in "内容", with: @post.content
    click_on "Create Post"

    assert_text "Post was successfully created"
  end

  test "should update Post" do
    visit post_url(@post)
    click_on "編集", match: :first

    fill_in "タイトル", with: @post.title
    fill_in "内容", with: @post.content
    click_on "Update Post"

    assert_text "Post was successfully updated"
  end

  test "should destroy Post" do
    visit post_url(@post)
    click_on "削除", match: :first

    assert_text "Post was successfully destroyed"
  end
end
