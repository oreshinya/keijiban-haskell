{-# LANGUAGE DeriveGeneric #-}
module Comment where

import GHC.Generics (Generic)
import Data.Aeson

data RequestedComment = RequestedComment { val :: String } deriving (Generic, Show)
data Comment = Comment { id :: Int, topicId :: Int, body :: String } deriving (Generic, Show)

instance FromJSON RequestedComment
instance ToJSON Comment
