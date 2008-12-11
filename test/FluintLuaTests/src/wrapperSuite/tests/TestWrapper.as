package wrapperSuite.tests
{
	import flash.display.Stage;
	import flash.utils.ByteArray;

	import luaalchemy.lua_wrapper;

	import net.digitalprimates.fluint.tests.TestCase;

	public class TestWrapper extends TestCase
	{
		public function TestWrapper()
		{
			super();
		}

		private var luaCtx:uint;
		override protected function setUp():void {
			luaCtx = lua_wrapper.luaCreateContext();
		}

		override protected function tearDown():void {
			lua_wrapper.luaClose(luaCtx);
		}


		public function testCreateCloseContext():void
		{
			var luaCtx:uint = lua_wrapper.luaCreateContext();
			assertTrue(luaCtx != 0);
			lua_wrapper.luaClose(luaCtx);
		}

		public function testDoScriptAdd():void
		{
			var stack:Array = lua_wrapper.luaDoString(luaCtx, "return 1+5");
			assertEquals(1, stack.length);
			assertEquals(6, stack[0]);
		}

		public function testAS3NewArray():void
		{
			var script:String = "v = as3.new(\"Array\")\nreturn v"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertTrue(stack[0] is Array);
		}

		public function testAS3NewByteArray():void
		{
			var script:String = "v = as3.new(\"flash.utils.ByteArray\")\nreturn v"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertTrue(stack[0] is ByteArray);
		}

		public function testAS3Release():void
		{
			var script:String = "v = as3.new(\"flash.utils.ByteArray\")\nas3.release(v)\nreturn v"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertNull(stack[0]);
		}

		public function testAS3ToLuaTypeNumber():void
		{
			var script:String = "n1 = as3.new(\"int\", 7)\nn2 = as3.new(\"Number\", 6)\nreturn as3.toluatype(n1) + as3.toluatype(n2)"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertEquals(13, stack[0]);
		}

		public function testBooleanToLuaType():void
		{
			var script:String = ( <![CDATA[
				bt = as3.new("Boolean", true)
				bf = as3.new("Boolean", false)
				return as3.toluatype(bt) == true, as3.toluatype(bf) == false, as3.toluatype(bt), as3.toluatype(bf)
				]]> ).toString();
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);

			assertEquals(4, stack.length);
			assertEquals(true, stack[0]);
			assertEquals(true, stack[1]);
			assertEquals(true, stack[2]);
			assertEquals(false, stack[3]);
		}

		// TODO test all Lua to boolean cast

		public function testAS3Class():void
		{
			var script:String = "v = as3.class(\"String\")\nreturn v"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertTrue(stack[0] is Class);
		}

		public function testAS3Get():void
		{
			var script:String = "v = as3.new(\"Array\")\nreturn as3.get(v, \"length\")"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertTrue(stack[0] is int);
			assertEquals(0, stack[0]);
		}


		// TODO test getting every possible type defined in push_as3_to_lua_stack(), also check type on lua end

		public function testAS3SetPublicString():void
		{
			var script:String = "v = as3.new(\"wrapperSuite.tests.TestWrapperHelper\")\nas3.set(v, \"string1\", \"hello\")\nreturn v, as3.get(v, \"string1\")"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);

			assertEquals(2, stack.length);

			assertTrue(stack[0] is TestWrapperHelper);
			var helper:TestWrapperHelper = stack[0] as TestWrapperHelper;
			assertEquals("hello", helper.string1);

			assertEquals("hello", stack[1]);
		}

		public function testAS3StringGetterSetter():void
		{
			var script:String = "v = as3.new(\"wrapperSuite.tests.TestWrapperHelper\")\nas3.set(v, \"string2\", \"hello\")\nreturn v, as3.get(v, \"string2\")"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);

			assertEquals(2, stack.length);

			assertTrue(stack[0] is TestWrapperHelper);
			var helper:TestWrapperHelper = stack[0] as TestWrapperHelper;
			assertEquals("hello", helper.string2);

			assertEquals("hello", stack[1]);
		}

		public function testAS3CallSetNameAge():void
		{
			var script:String = ( <![CDATA[
				v = as3.new("wrapperSuite.tests.TestWrapperHelper")
				as3.call(v, "setNameAge", "Robert", 38)
				return as3.get(v, "nameAge")
				]]> ).toString();
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);

			assertEquals(1, stack.length);
			assertEquals("Name: Robert age: 38", stack[0]);
		}

		public function testAS3CallStaticNameAge():void
		{
			var script:String = ( <![CDATA[
				v = as3.class("wrapperSuite.tests.TestWrapperHelper")
				return as3.call(v, "staticNameAge", "Jessie James", 127)
				]]> ).toString();
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);

			assertEquals(1, stack.length);
			assertEquals("Name: Jessie James age: 127", stack[0]);
		}

		public function testAS3Yield():void
		{
			var script:String = ( <![CDATA[
				as3.yield()
				]]> ).toString();
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);

			assertEquals(0, stack.length);
		}

		public function testAS3Metatable():void
		{
			var script:String = ( <![CDATA[
				as3.get(io.stdin, "bad")
				]]> ).toString();
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);

			assertEquals(1, stack.length);
			assertEquals("[string \"...\"]:2: bad argument #1 to 'get' (LuaAlchemy.as3 expected, got userdata)", stack[0]);
		}

/*
		// TODO the stage isn't crossing the C/Lua or Alchemy bindings intact
		public function testAS3Stage():void
		{
			var script:String = ( <![CDATA[
				return as3.stage()
				]]> ).toString();
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);

			assertEquals(1, stack.length);
			assertTrue(stack[0] is Stage);
		}

		public function testAS3Assign():void
		{
		}

		public function testAS3Type():void
		{
		}

		public function testAS3Classname():void
		{
		}
*/
	}
}
