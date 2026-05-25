mod bindings {
    use super::Component;
    wit_bindgen::generate!();
    export!(Component);
}

struct Component;

impl bindings::exports::test::rust::foo::Guest for Component {
    fn foo() -> String {
        "Hello World!".into()
    }
}
