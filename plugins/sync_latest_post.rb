require './plugins/sync_post.rb'

syncPost = MetaWeblogSync::SyncPost.new $*[0]
syncPost.postLatestBlog