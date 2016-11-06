{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import Web.Spock
import Web.Spock.Config
import Database.MySQL.Simple
import qualified TopicParams as TP (Params(..))
import qualified Topic as T (Topic(..))
import qualified CommentParams as CP (Params(..))
import qualified Comment as C (Comment(..))

openDBConnection :: IO Connection
openDBConnection = connect defaultConnectInfo { connectDatabase = "keijiban" }

closeDBConnection :: Connection -> IO ()
closeDBConnection = close

dbConnectionBuilder :: ConnBuilder Connection
dbConnectionBuilder = ConnBuilder openDBConnection closeDBConnection (PoolCfg 1 1 30)

appCfg :: IO (SpockCfg Connection () ())
appCfg = defaultSpockCfg () (PCConn dbConnectionBuilder) ()

app :: SpockM Connection () () ()
app = do
    post "topics" $ do
      (TP.Params (Just n)) <- jsonBody'
      (Only i:_) <- runQuery $ \conn -> do
        execute conn "INSERT INTO topics (name) VALUES (?)" [n]
        query_ conn "SELECT LAST_INSERT_ID()"
      json $ T.Topic i n

    get "topics" $ do
      xs <- runQuery $ \conn -> do
        query_ conn "SELECT id, name FROM topics ORDER BY id DESC"
      json $ map (\(i, n) -> T.Topic i n) xs

    post ("topics" <//> var <//> "comments") $ \(x :: Int) -> do
      (CP.Params (Just b)) <- jsonBody'
      (Only i:_) <- runQuery $ \conn -> do
        execute conn "INSERT INTO comments (topic_id, body) VALUES (?, ?)" (x :: Int, b :: String)
        query_ conn "SELECT LAST_INSERT_ID()"
      json $ C.Comment i x b

    get ("topics" <//> var <//> "comments") $ \(x :: Int) -> do
      xs <- runQuery $ \conn -> do
        query conn "SELECT id, topic_id, body FROM comments WHERE topic_id = ?" [x]
      json $ map (\(id, topicId, body) -> C.Comment id topicId body) xs

main :: IO ()
main = do
    spockCfg <- appCfg
    runSpock 8080 (spock spockCfg app)
