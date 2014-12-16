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

    # Fill in backtrace
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

  def test_request_log_via_rack_env
    require 'rack/request'
    @options = {
      table_name: 'sample_table',
      database: 'sample',
      test_mode: true,
      apikey: 'deadbeaf19842015'
    }
    @env = {
      "HTTP_HOST" => "example.udzura.jp:80",
      "rack.url_scheme" => 'http',
      "PATH_INFO" => "/hello.html",
      "REQUEST_METHOD" => "GET",
      "HTTP_COOKIE" => "foo=bar;buz=1234;",
      "HTTP_REFERER" => "http://example.com",
    }

    notifier_with_test_mode.call(StandardError.new("sample error"), {env: @env})
    posted = TD.logger.queue[0]

    assert_equal posted[:request_url], "http://example.udzura.jp/hello.html"
    assert_equal posted[:method], "GET"
    assert_equal posted[:cookies], {"foo"=>"bar", "buz"=>"1234"}
    assert_equal posted[:referer], "http://example.com"
    # TODO: add request body assertion
  end

  def test_custom_param_proc
    @options = {
      table_name: 'sample_table',
      database: 'sample',
      test_mode: true,
      apikey: 'deadbeaf19842015',
      custom_param_proc: proc {|info|
        info[:hello] = "world"
      }
    }

    notifier_with_test_mode.call(StandardError.new("sample error"), {env: @env})
    posted = TD.logger.queue[0]

    assert_equal posted[:hello], "world"
  end

  def test_backtrace_limit
    @options = {
      table_name: 'sample_table',
      database: 'sample',
      test_mode: true,
      apikey: 'deadbeaf19842015'
    }

    # Fill in backtrace
    begin
      raise StandardError, "sample error"
    rescue => e
      notifier_with_test_mode.call(e, {})
    end

    posted = TD.logger.queue[0]
    assert_equal posted[:backtrace].size, 10

    @notifier = nil
    @options = {
      table_name: 'sample_table',
      database: 'sample',
      test_mode: true,
      apikey: 'deadbeaf19842015',
      backtrace_limit: 5
    }
    begin
      raise StandardError, "sample error 2"
    rescue => e
      notifier_with_test_mode.call(e, {})
    end

    posted = TD.logger.queue[0]
    assert_equal posted[:backtrace].size, 5
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
