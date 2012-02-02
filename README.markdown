# statec

## introduction

Pronounced "static", statec is an Objective-C/Foundation tool to compile Obj-C state machine classes from a little language that describes them.

The goal was to have a simple, clear, language to express a state machine that compiles into an easy to use class to operate them. There are other, similar, tools available for example [SMC](http://smc.sourceforge.net/) or [Ragel](http://www.complang.org/ragel/) which are more comprehensive, support a wide range of languages, and so forth. They are good tools but they did not immediately fit my needs and thus began a monumental exercise in Yak shaving.

Two days later and I have a "little language" for expressing state machines that is parsed - using a parser built with Tom Davie's [CoreParse](https://github.com/beelsebob/CoreParse) framework (itself quite young but promising) - into an intermediate representation of a machine and then converted directly into Objective-C source using an Objective-C code generator framework built as part of the framework.

Similar to the approach taken by Rentzsch's [mogenerator](https://github.com/rentzsch/mogenerator) statec generates two classes for each machine, a completely generated implementation class and a user-managed class that subclasses it. The implementation provides methods to respond to state changes that the user-managed class can override to provide context specific processing.

## language

The statec language is a little language for describing state machines. It has a few keywords and a simple structure, here's an example:

<code><pre>
@machine "TrafficLight" {
  @initial "off"
	@state "off" {
		@event "on" => "green"
	}
	@state "green" {
		@enter
		@exit
		@event "amber" => "amber"
		@event "off" => "off"
	}
	@state "amber" {
		@enter
		@exit
		@event "green" => "green"
		@event "red" => "red"
	}
	@state "red" {
		@enter
		@exit
		@event "amber" => "amber"
	}
}
</pre></code>

<dl>
	<dt>@machine</dt>
	<dd>names the machine and contains its states. The name is used as the basis of the classes generated, in our example they would be _TrafficLightMachine (the implementation class) and TrafficLightMachine (the user class).</dd>
	<dt>@initial</dt>
	<dd>defines the initial state of the machine (an enter event is not generated for the machine being started in this state).</dd>
	<dt>@state</dt>
	<dd>defines a named state</dd>
	<dt>@enter</dt>
	<dd>specifies that a callback (e.g. enterGreenState) should be generated and invoked when the machine enters this state.</dd>
	<dt>@exit</dt>
	<dd>specifies than a callback (e.g. exitAmberState) should be generated and invoked before the machine leaves this state.</dd>
	<dt>@event</dt>
	<dd>defines a named event and the state the event transitions the machine into. The event name is used to name the event method in the machine (e.g. amberEvent) to cause the transition.</dd>
</dl>

The current behaviour is to raise an exception when an event is invoked that is not legal in the current state. In the future this might - optionally - return a condition & NSError instead.

## running

The statec command line tool requires the CoreParse.framework be installed in /Library/Frameworks.

The statec command line tool has two arguments:

* -i &lt;machine file&gt; 
	* e.g. trafficlight.smd
* -d &lt;target folder&gt;
	* e.g. ~/Projects/TrafficLightSim/

The generated files should be added to your Xcode project. The *\_&lt;Name&gt;Machine.m* file should not be edited as this will be regenerated every time the statec command is generated. The *&lt;Name&gt;Machine.m* is intended for the user to edit and will not be regenerated if it exists.

## machine

The generated machine does not employ a switch statement or lookup table but, rather, stateless classes that represent the states in the machine and that have methods that represent the available transitions.

In our example a class `TrafficLightState` is generated along with a subclass for each state, e.g. `TrafficLightOnState`. The `TrafficLightMachine` has a state variable that points at an instance representing the current state. When an event method e.g. `greenEvent` is called on the machine it is passed to the current state class that either transitions the calling machine into a new state (optionally invoking exit & enter callbacks), or raises an exception if the transition is not legal from that state.
