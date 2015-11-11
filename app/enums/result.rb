class Result < ClassyEnum::Base
end

class Result::Reject < Result
end

class Result::Done < Result
end