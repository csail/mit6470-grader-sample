# Base class of all problems.
class Problem
  # Override this method.
  def grade()
  end

  # @return [Hash<String, Object>] test case data
  attr_reader :data

  # @return [String] compiled version of the user's submission
  attr_reader :compiled_code

  # @return [WebkitRemote::Client]
  attr_reader :browser

  # @return [String] the URL of the test HTML server
  def test_url
    test_port = ENV['PORT'].to_i + 100
    @test_url ||= "http://127.0.0.1:#{test_port}/"
  end

  # @return [String] the URL of the CORS test server
  def cors_app_url
    cors_port = ENV['PORT'].to_i + 200
    @cors_url ||= "http://127.0.0.1:#{cors_port}/"
  end

  # Called if the solution solved the problem.
  def correct
    raise VerdictException.new(1, 'Accepted')
  end

  # Called if the solution is incorrect.
  def wrong(reason)
    raise VerdictException.new(0, reason)
  end

  # Appends text to a contestant-visible log.
  def log(message)
    @log_entries << message
  end

  class <<self
    # @return [String] name used in URLs and forms
    def param_name(new_param_name = nil)
      (new_param_name == nil) ? @param_name : (@param_name = new_param_name)
    end

    # @return [String] user-friendly name
    def name(new_name = nil)
      (new_name == nil) ? @name : (@name = new_name)
    end

    # @return [Integer] number of seconds to wait before the test completes
    def time_limit(new_time_limit = nil)
      (new_time_limit == nil) ? @time_limit : (@time_limit = new_time_limit)
    end

    # Code that builds up the test case.
    def setup(&setup_block)
      define_method :testcase_setup, &setup_block
    end

    # Code that performs the test.
    def grade(&grade_block)
      define_method :testcase_grader, &grade_block
    end

    # @return [Array<Problem>] all the problems
    attr_reader :all

    # Loads the definitions for all the problems.
    #
    # @return [Array<Problem>] all the problems
    def load_all
      sources = Dir[File.join(root, '*.rb')]
      sources.each do |source|
        require source
      end
      all
    end

    # Called when someone inherits from this class.
    def inherited(klass)
      @all << klass
    end

    # @return [String] path to the problem definition files
    def root
      @root ||= File.expand_path '../problems', File.dirname(__FILE__)
    end
  end

  @all = []

  # Sets up a problem for grading.
  def initialize
    @data = {}
    @log_entries = []
    @test_template = Tilt.new File.join(self.class.root,
                                        self.class.param_name + '.html.erb')
    @browser_port = (ENV['PORT']).to_i + 50
    @browser = nil

    @verdict_score = nil
    @verdict_reason = nil
    @js_libraries = []

    testcase_setup
  end

  # Compiles the user's code.
  def code=(code)
    lines = code.lines.to_a

    lang_match = /\scompiler:\s+(\w+)\s+/.match lines[0]
    if lang_match
      begin
        case lang_match[1].downcase
        when 'css', 'javascript', 'js'
          @compiled_code = code
        when 'coffee', 'coffeescript'
          @compiled_code = CoffeeScript.compile code, bare: true
        when 'less'
          @compiled_code = Less::Parser.new.parse(code).to_css
        when 'sass'
          @compiled_code = Sass::Engine.new(code, syntax: :sass).render
        when 'scss'
          @compiled_code = Sass::Engine.new(code, syntax: :scss).render
        else
          raise RuntimeError, 'Unknown compiler'
        end
      rescue StandardError => e
        @compiled_code =
            '</style></script><script>alert("Compilation error!");</script>'
        @verdict_score = 0
        @verdict_reason = 'Compilation error'
      end
    else
      @compiled_code = code
    end

    lines.each do |line|
      lib_match = /\sjs_library:\s+(\S+)\s+/.match line
      if lib_match
        @js_libraries << lib_match[1]
      end
    end
  end

  # The grading process.
  def grade
    return self if @verdict_score

    begin
      @browser = WebkitRemote.local port: @browser_port, xvfb: true
      browser.clear_cookies
      browser.clear_network_cache
      browser.disable_cache = true
      Timeout.timeout self.class.time_limit do
        testcase_grader
      end
      raise RuntimeError, 'Grader did not produce a verdict'
    rescue VerdictException => e
      # The grader called "correct" or "wrong".
      @verdict_score = e.score
      @verdict_reason = e.reason
    rescue Timeout::Error
      # The user's code most likely got stuck.
      @verdict_score = 0
      @verdict_reason = 'Time Limit Exceeded'
    ensure
      @browser.close if @browser
      @browser = nil
    end
    self
  end

  # @return [Number]
  attr_reader :verdict_score

  # @return [String]
  attr_reader :verdict_reason

  # @return [String] contestant-visible extended grading info
  def log_contents
    @log_contents ||= @log_entries.join("\n")
  end

  # Uploads the test HTML to the test server.
  def upload_test_html
    Net::HTTP.post_form URI.parse(test_url), html: test_html
    self
  end

  # @return [String] the HTML for testing this problem
  def test_html
    @test_html ||= @test_template.render Object.new, data: data,
        test_url: test_url, compiled_code: compiled_code,
        js_library_tags: js_library_tags
  end

  # @return [String] empty string or <script> tags that require JS libraries
  def js_library_tags
    @js_libraries.map { |js_lib|
      lib_url = "//cdnjs.cloudflare.com/ajax/libs/#{js_lib}"
      %Q|<script type="text/javascript" src="#{lib_url}"></script>|
    }.join "\n"
  end

  # This method gets overriden when "setup" is called.
  def testcase_setup
  end
  private :testcase_setup

  # This method gets overridden when "grade" is called.
  def testcase_grader
  end
  private :testcase_grader
end

# Defines a problem.
def problem(&definition_block)
  Class.new(Problem).class_eval(&definition_block)
end

# Thrown when correct or wrong are called.
class VerdictException < Exception
  # @return [String] will be output as the grading message
  attr_reader :reason

  # @return [Number]
  attr_reader :score

  def initialize(score, reason)
    @score = score
    @reason = reason
  end
end

# Test::Unit-like DSL for checking values.
module ProblemAssertions
  # Equality check.
  def assert_equal(expected, actual, message = '')
    return if expected == actual
    wrong "#{message} expected: #{expected.inspect}, actual: #{actual.inspect}"
  end

  # Approximate equality check.
  def assert_close_to(expected, actual, delta, message = '')
    return if (expected - actual).abs <= delta
    wrong "#{message} expected: #{expected.inspect} +/- #{delta.inspect}, actual: #{actual.inspect}"
  end

  # Approximate equality check for array elements.
  def assert_each_close_to(expected, actual, delta, message = '')
    if expected.length != actual.length
      wrong "#{message} expected: #{expected.length} items, actual: #{actual.length} items"
    end
    if expected.each_index.all? { |i| (expected[i] - actual[i]).abs <= delta }
      return
    end
    wrong "#{message} expected: #{expected.inspect} +/- #{delta.inspect}, actual: #{actual.inspect}"
  end
end
class Problem
  include ProblemAssertions
end

# DSL for CSS manipulations
module ProblemHelpers
  def bounding_rect(dom_node)
    js_object = if dom_node.kind_of? WebkitRemote::Client::JsObject
      dom_node
    else
      dom_node.js_object
    end
    js_rect = js_object.bound_call(
        'function() { return this.getBoundingClientRect(); }')
    Hash[[:width, :height, :top, :bottom, :left, :right].map { |key|
      [key, js_rect.properties[key.to_s].value]
    }]
  end

  def inner_html(dom_node)
    js_object = if dom_node.kind_of? WebkitRemote::Client::JsObject
      dom_node
    else
      dom_node.js_object
    end
    js_object.bound_call 'function() { return this.innerHTML; }'
  end

  def inner_text(dom_node)
    js_object = if dom_node.kind_of? WebkitRemote::Client::JsObject
      dom_node
    else
      dom_node.js_object
    end
    js_object.bound_call 'function() { return this.innerText; }'
  end

  def input_value(dom_node)
    js_object = if dom_node.kind_of? WebkitRemote::Client::JsObject
      dom_node
    else
      dom_node.js_object
    end
    js_object.bound_call 'function() { return this.value; }'
  end

  def set_input_value(dom_node, value)
    js_object = if dom_node.kind_of? WebkitRemote::Client::JsObject
      dom_node
    else
      dom_node.js_object
    end
    js_object.bound_call 'function(v) { this.value = v; }', value
  end
end
class Problem
  include ProblemHelpers
end
