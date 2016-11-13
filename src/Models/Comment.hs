{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Models.Comment where

import Database.MySQL.Simple
import Database.MySQL.Simple.QueryResults
import GHC.Generics (Generic)
import Data.Aeson

type TopicId = Int
type Body = String
data Comment = Comment { id :: Int, topicId :: TopicId, body :: Body } deriving (Generic, Show)

instance ToJSON Comment

selectByTopicId :: QueryResults r => TopicId -> Connection -> IO [r]
selectByTopicId t conn = query conn "SELECT id, topic_id, body FROM comments WHERE topic_id = ?" [t]

create :: QueryResults r => TopicId -> Body -> Connection -> IO [r]
create t b conn = do
    execute conn "INSERT INTO comments (topic_id, body) VALUES (?, ?)" (t :: TopicId, b :: Body)
    query_ conn "SELECT LAST_INSERT_ID()"
