{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Models.Topic where

import Database.MySQL.Simple
import Database.MySQL.Simple.QueryResults
import GHC.Generics (Generic)
import Data.Aeson

type Name = String
data Topic = Topic { id :: Int, name :: Name } deriving (Generic, Show)

instance ToJSON Topic

selectLatest :: QueryResults r => Connection -> IO [r]
selectLatest conn = query_ conn "SELECT id, name FROM topics ORDER BY id DESC"

create :: QueryResults r => Name -> Connection -> IO [r]
create n conn = do
    execute conn "INSERT INTO topics (name) VALUES (?)" [n]
    query_ conn "SELECT LAST_INSERT_ID()"
