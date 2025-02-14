---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Flaky tests

## What's a flaky test?

It's a test that sometimes fails, but if you retry it enough times, it passes,
eventually.

## Quarantined tests

When a test frequently fails in `main`,
create [a ~"failure::flaky-test" issue](https://about.gitlab.com/handbook/engineering/workflow/#broken-master).

If the test cannot be fixed in a timely fashion, there is an impact on the
productivity of all the developers, so it should be quarantined by
assigning the `:quarantine` metadata with the issue URL, and add the `~"quarantined test"` label to the issue.

```ruby
it 'succeeds', quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/12345' do
  expect(response).to have_gitlab_http_status(:ok)
end
```

This means it is skipped unless run with `--tag quarantine`:

```shell
bin/rspec --tag quarantine
```

Once a test is in quarantine, there are 3 choices:

- Fix the test (that is, get rid of its flakiness).
- Move the test to a lower level of testing.
- Remove the test entirely (for example, because there's already a
  lower-level test, or it's duplicating another same-level test, or it's testing
  too much etc.).

## Automatic retries and flaky tests detection

On our CI, we use [RSpec::Retry](https://github.com/NoRedInk/rspec-retry) to automatically retry a failing example a few
times (see [`spec/spec_helper.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/spec/spec_helper.rb) for the precise retries count).

We also use a custom [`RspecFlaky::Listener`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/tooling/rspec_flaky/listener.rb).
This listener runs in the `update-tests-metadata` job in `maintenance` scheduled pipelines
on the `master` branch, and saves flaky examples to `rspec/flaky/report-suite.json`.
The report file is then retrieved by the `retrieve-tests-metadata` job in all pipelines.

This was originally implemented in: <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/13021>.

If you want to enable retries locally, you can use the `RETRIES` environment variable.
For instance `RETRIES=1 bin/rspec ...` would retry the failing examples once.

To generate the reports locally, use the `FLAKY_RSPEC_GENERATE_REPORT` environment variable.
For example, `FLAKY_RSPEC_GENERATE_REPORT=1 bin/rspec ...`.

### Usage of the `rspec/flaky/report-suite.json` report

The `rspec/flaky/report-suite.json` report is:

- Used for [automatically skipping known flaky tests](../pipelines.md#automatic-skipping-of-flaky-tests).
- [Imported into Snowflake](https://gitlab.com/gitlab-data/analytics/-/blob/master/extract/gitlab_flaky_tests/upload.py)
  once per day, for monitoring with the [internal dashboard](https://app.periscopedata.com/app/gitlab/888968/EP---Flaky-tests).

## Problems we had in the past at GitLab

- [`rspec-retry` is biting us when some API specs fail](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/29242): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/9825>
- [Sporadic RSpec failures due to `PG::UniqueViolation`](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/28307#note_24958837): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/9846>
  - Follow-up: <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10688>
  - [Capybara.reset_session! should be called before requests are blocked](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/33779): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/12224>
- FFaker generates funky data that tests are not ready to handle (and tests should be predictable so that's bad!):
  - [Make `spec/mailers/notify_spec.rb` more robust](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/20121): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10015>
  - [Transient failure in `spec/requests/api/commits_spec.rb`](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/27988#note_25342521): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/9944>
  - [Replace FFaker factory data with sequences](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/29643): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10184>
  - [Transient failure in spec/finders/issues_finder_spec.rb](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/30211#note_26707685): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10404>

### Order-dependent flaky tests

These flaky tests can fail depending on the order they run with other tests. For example:

- <https://gitlab.com/gitlab-org/gitlab/-/issues/327668>

To identify the tests that lead to such failure, we can use `scripts/rspec_bisect_flaky`,
which would give us the minimal test combination to reproduce the failure:

1. First obtain the list of specs that ran before the flaky test. You can search
   for the list under `Knapsack node specs:` in the CI job output log.
1. Save the list of specs as a file, and run:

    ```shell
    cat knapsack_specs.txt | xargs scripts/rspec_bisect_flaky
    ```

If there is an order-dependency issue, the script above will print the minimal
reproduction.

### Time-sensitive flaky tests

- <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10046>
- <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10306>

### Array order expectation

- <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10148>

### Feature tests

- [Be sure to create all the data the test need before starting exercise](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/32622#note_31128195): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/12059>
- [Bis](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/34609#note_34048715): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/12604>
- [Bis](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/34698#note_34276286): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/12664>
- [Assert against the underlying database state instead of against a page's content](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/31437): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10934>
- In JS tests, shifting elements can cause Capybara to mis-click when the element moves at the exact time Capybara sends the click
  - [Dropdowns rendering upward or downward due to window size and scroll position](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/17660)
  - [Lazy loaded images can cause Capybara to mis-click](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/18713)
- [Triggering JS events before the event handlers are set up](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/18742)
- [Wait for the image to be lazy-loaded when asserting on a Markdown image's `src` attribute](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/25408)
- [Avoid asserting against flash notice banners](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/79432)

#### Capybara viewport size related issues

- [Transient failure of spec/features/issues/filtered_search/filter_issues_spec.rb](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/29241#note_26743936): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10411>

#### Capybara JS driver related issues

- [Don't wait for AJAX when no AJAX request is fired](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/30461): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/10454>
- [Bis](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/34647): <https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/12626>

#### Capybara expectation times out

- [Test imports a project (via Sidekiq) that is growing over time, leading to timeouts when the import takes longer than 60 seconds](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/22599)

### Hanging specs

If a spec hangs, it might be caused by a [bug in Rails](https://github.com/rails/rails/issues/45994):

- <https://gitlab.com/gitlab-org/gitlab/-/merge_requests/81112>
- <https://gitlab.com/gitlab-org/gitlab/-/issues/337039>

## Resources

- [Flaky Tests: Are You Sure You Want to Rerun Them?](https://semaphoreci.com/blog/2017/04/20/flaky-tests.html)
- [How to Deal With and Eliminate Flaky Tests](https://semaphoreci.com/community/tutorials/how-to-deal-with-and-eliminate-flaky-tests)
- [Tips on Treating Flakiness in your Rails Test Suite](https://semaphoreci.com/blog/2017/08/03/tips-on-treating-flakiness-in-your-test-suite.html)
- ['Flaky' tests: a short story](https://www.ombulabs.com/blog/rspec/continuous-integration/how-to-track-down-a-flaky-test.html)
- [Using Insights to Discover Flaky, Slow, and Failed Tests](https://circleci.com/blog/using-insights-to-discover-flaky-slow-and-failed-tests/)

---

[Return to Testing documentation](index.md)
