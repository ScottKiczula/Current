class TrendsController < ApplicationController
  include ApiHelper

  def index
    if request.xhr?
      @trends = []
      counter = 24
      until counter < 1
        @trends << Trend.order('created_at DESC').find_by(rank: counter)
        counter -= 1
      end
      @trends = @trends.reverse
      render partial: "trends/tile", layout: false
    else
      # Get Trends from current date & time (LIVE)
      @trends = []
      counter = 24
      until counter < 1
        @trends << Trend.order('created_at DESC').find_by(rank: counter)
        counter -= 1
      end
      @trends = @trends.reverse
    end
  end

  def show
    @trend = Trend.find(params[:id])
    @tweets_array = @trend.tweets
  end

  def api
    # Get Top 50 Twitter Trends and put them into an array
    @trends_array = []
    twitter.trends(id = 23424977, options = {}).each do |trend|
      @trends_array << trend.name
    end

    @trends_array = @trends_array[0..23]
    @trends_array[17] = "SpaceX"
    # Create Trend Objects and populate them with the Trend and Thumbnail
    bing
    counter = 1
    @trends_array.each do |trend|
      puts trend
      image_result = BingSearch.image(trend)
      puts "__________________________"
      puts image_result.first.to_json
        if image_result.first == nil
          trend_object = Trend.create(name: trend, thumbnail: "https://avatars0.githubusercontent.com/u/55462?v=3&s=400", rank: counter)
          Image.create(url: "https://pbs.twimg.com/profile_images/715912004914044928/l4oNQ_pi.jpg", trend_id: trend_object.id)
          Image.create(url: "https://a1-images.myspacecdn.com/images02/149/36f8c7c493724afe9e7f06d62af006a7/300x300.jpg", trend_id: trend_object.id)
          Image.create(url: "https://pbs.twimg.com/profile_images/542694723278757888/2tdeBa2A.jpeg", trend_id: trend_object.id)
          # Image.create(url: "https://static1.squarespace.com/static/53e4e1bbe4b08bfde27b5214/53e5176ae4b0990b0972dd46/576044891bbee08251f0ad26/1466095802553/DSC01810.jpg?format=1500w", trend_id: trend_object.id)
          # Image.create(url: "https://mir-s3-cdn-cf.behance.net/user/276/6303587.53a222160ddca.jpg", trend_object.id)
          # Image.create(url: "https://i.ytimg.com/vi/4q0rjxpzBnE/hqdefault.jpg", trend_object.id)
        else
          trend_object = Trend.create(name: trend, thumbnail: image_result.first.thumbnail.media_url, rank: counter)
          image_result.each do |image|
            Image.create(url: image.media_url, trend_id: trend_object.id)
          end
        end

        news_result = BingSearch.news(trend)
        puts "__________________________"
        puts news_result.first.to_json
          if news_result.first == nil
            Link.create(name: "Tom Brady is the Greatest Ever", url: "http://grantland.com/the-triangle/he-lives-for-that-s%E2%80%8B-%E2%80%8B-t-how-37-year-old-tom-brady-dismantled-one-of-the-greatest-defenses-ever/", trend_id: trend_object.id)
          else
            news_result.each do |news|
              Link.create(name: news.title, url: news.url, trend_id: trend_object.id)
            end
          end

          top_tweets = twitter.search(trend, options = {:result_type => "popular"})
          top_tweets.each do |tweet|
            Tweet.create(tweet: tweet.id, trend_id: trend_object.id)
          end
      counter += 1
    end
  end


end
