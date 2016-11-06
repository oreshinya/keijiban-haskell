{-# LANGUAGE DeriveGeneric #-}
module Comment where

import GHC.Generics (Generic)
import Data.Aeson

data Comment = Comment { id :: Int, topicId :: Int, body :: String } deriving (Generic, Show)

instance ToJSON Comment
