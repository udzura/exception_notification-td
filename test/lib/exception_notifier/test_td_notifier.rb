class TestTdNotifier < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_normal_setup
    @options = {
      table_name: 'sample_table',
      database: 'sample',
      backtrace_limit: 100,
      custom_param_proc: proc {|i| i[:foo] = "bar"; i },
      apikey: 'deadbeaf19842015'
    }

    assert_equal notifier.table_name, 'sample_table'
    assert_equal notifier.database,   'sample'
    assert_equal notifier.backtrace_limit, 100
    assert_equal notifier.custom_param_proc[{}], {foo: "bar"}

    apikey = TreasureData::Logger.logger.instance_eval{ @client }.apikey
    assert_equal apikey, "deadbeaf19842015"
  end

  def test_required_options
    @options = {}
    assert_raise_message /Please set table_name/ do
      ExceptionNotifier::TdNotifier.new(@options)
    end

    @options[:table_name] = "ganbaruzoi"
    assert_raise_message /Please set database/ do
      ExceptionNotifier::TdNotifier.new(@options)
    end
  end

  def test_post_message
    @options = {
      table_name: 'sample_table',
      database: 'sample',
      test_mode: true,
      apikey: 'deadbeaf19842015'
    }

    begin
      @l = __LINE__; raise StandardError, "sample error"
    rescue => e
      notifier_with_test_mode.call(e, {})
    end

    posted = TD.logger.queue[0]
    assert_equal posted[:class], "StandardError"
    assert_equal posted[:message], "sample error"
    assert_match %r|#{Regexp.quote __FILE__}:#{@l}|, posted[:backtrace][0]
    assert_not_nil posted[:hostname]
    assert_not_nil posted[:environment]
  end

  private

  def notifier
    @notifier ||= ExceptionNotifier::TdNotifier.new(@options)
  end

  def notifier_with_test_mode
    @notifier ||= begin
                    n = ExceptionNotifier::TdNotifier.new(@options)
                    TreasureData::Logger.open_test
                    n
                  end
  end
end
