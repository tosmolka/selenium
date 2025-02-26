# frozen_string_literal: true

# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require_relative 'spec_helper'

module Selenium
  module WebDriver
    describe BiDi, only: {browser: %i[chrome edge firefox]} do
      before { reset_driver!(web_socket_url: true) }
      after { quit_driver }

      it 'gets session status' do
        status = driver.bidi.session.status
        expect(status).to respond_to(:ready)
        expect(status.message).not_to be_empty
      end

      it 'can navigate and listen to errors', except: {browser: :chrome, reason: 'not yet implemented'} do
        log_entry = nil
        log_inspector = BiDi::LogInspector.new(driver)
        log_inspector.on_javascript_exception { |log| log_entry = log }

        browsing_context = BiDi::BrowsingContext.new(driver: driver, browsing_context_id: driver.window_handle)
        info = browsing_context.navigate(url: url_for('/bidi/logEntryAdded.html'))

        expect(browsing_context.id).not_to be_nil
        expect(info.navigation_id).to be_nil
        expect(info.url).to include('/bidi/logEntryAdded.html')

        driver.find_element(id: 'jsException').click
        wait.until { !log_entry.nil? }

        expect(log_entry).to have_attributes(
          text: "Error: Not working",
          type: "javascript",
          level: BiDi::LogInspector::LOG_LEVEL[:ERROR]
        )
      end
    end
  end
end
