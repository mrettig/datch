class SqlPatch

  attr_reader :change, :rollback

  def initialize(change, rollback=nil)
    @change=change
    @rollback=rollback
  end


end