use tao::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};
use wry::webview::{WebViewBuilder, WebContext};
use std::path::PathBuf;

fn main() -> wry::Result<()> {
    // --- FIX START ---
    unsafe {
        // 1. Tetap matikan Compositing (Penting untuk anti-lag di scrolling)
        std::env::set_var("WEBKIT_DISABLE_COMPOSITING_MODE", "1");
        
        // 2. Tetap matikan DMABuf (Penyebab utama freeze total di Hyprland)
        std::env::set_var("WEBKIT_DISABLE_DMABUF_RENDERER", "1");
        
        // 3. HAPUS/COMMENT baris 'WEBKIT_DISABLE_ACCELERATED_2D_CANVAS'
        // Kita butuh ini ON supaya fitur Google (Translate/AI) bisa menggambar UI-nya.
    }
    // -----------------

    let event_loop = EventLoop::new();
    
    // Konfigurasi Window
    let window = WindowBuilder::new()
        .with_title("Search Launcher")
        .with_inner_size(tao::dpi::LogicalSize::new(800.0, 500.0))
        .with_decorations(false)
        .with_transparent(true) 
        .build(&event_loop)
        .unwrap();

    // Konfigurasi Penyimpanan Data
    let home_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    let data_path = PathBuf::from(&home_dir).join(".config/search_launcher_data");
    
    if !data_path.exists() {
        std::fs::create_dir_all(&data_path).unwrap_or_default();
    }

    let mut web_context = WebContext::new(Some(data_path));

    // User Agent Chrome (Agar Google menganggap kita browser modern)
    let user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

    // JANGAN LUPA: Ganti path file HTML di bawah ini
    let _webview = WebViewBuilder::new(window)?
        .with_url("file:///home/rogan/.config/my-plugins/search_launcher/da-web/search.html")? 
        .with_web_context(&mut web_context)
        .with_transparent(true)
        .with_user_agent(user_agent) // <--- Kita menyamar jadi Chrome
        .build()?;

    // Jalankan Loop
    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}
