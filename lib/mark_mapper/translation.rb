# encoding: UTF-8
module MarkMapper
  module Translation
    include ActiveModel::Translation

    def i18n_scope
      :mark_mapper
    end
  end
end