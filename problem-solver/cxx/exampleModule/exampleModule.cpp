/*
* This source file is part of an OSTIS project. For the latest info, see http://ostis.net
* Distributed under the MIT License
* (See accompanying file COPYING.MIT or copy at http://opensource.org/licenses/MIT)
*/

#include "exampleModule.hpp"
#include "keynodes/keynodes.hpp"
#include "agents/SubdividingSearchAgent.hpp"

using namespace exampleModule;

SC_IMPLEMENT_MODULE(ExampleModule)

sc_result ExampleModule::InitializeImpl()
{
  if (!exampleModule::Keynodes::InitGlobal())
    return SC_RESULT_ERROR;

  SC_AGENT_REGISTER(SubdividingSearchAgent)

  return SC_RESULT_OK;
}

sc_result ExampleModule::ShutdownImpl()
{
  SC_AGENT_UNREGISTER(SubdividingSearchAgent)

  return SC_RESULT_OK;
}
