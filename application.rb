# The one and only controller.
class GraderApp < Sinatra::Base
  get '/' do
    @problems = Problem.all
    erb :"grdr/form"
  end

  post '/' do
    @problem_name = params[:task]
    problem_class = Problem.all.find do |problem|
      problem.param_name == @problem_name
    end
    unless problem_class
      status :not_found
      return
    end

    @problem = problem_class.new
    @problem.code = params[:code]

    if params[:debug] == 'true'
      content_type :html
      @problem.test_html
    else
      @problem.upload_test_html
      @problem.grade

      headers['X-Grader-MaxScore'] = 1.to_s
      headers['X-Grader-Score'] = @problem.verdict_score.to_s
      headers['X-Grader-Verdict'] = @problem.verdict_reason
      erb :"grdr/verdict"
    end
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  set :erb, trim: '-'
  enable :dump_errors, :logging
  disable :sessions
end

# Dynamically load problem definitions.
require './lib/problem.rb'
Problem.load_all
