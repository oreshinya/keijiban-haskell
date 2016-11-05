{-# LANGUAGE DeriveGeneric #-}
module Topic where

import GHC.Generics (Generic)
import Data.Aeson

data RequestedTopic = RequestedTopic { val :: String } deriving (Generic, Show)
data Topic = Topic { id :: Int, name :: String } deriving (Generic, Show)

instance FromJSON RequestedTopic
instance ToJSON Topic
