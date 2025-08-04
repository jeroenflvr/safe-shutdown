use std::fs::File;
use std::path::Path;
use std::{fs, io};

const SENTINEL_FILE: &str = ".safe_shutdown";

#[derive(Debug)]
pub struct Safener {
    pub path: String,
    pub sentinel_file: String,
}

fn create_directories<P: AsRef<Path>>(path: P) -> io::Result<()> {
    fs::create_dir_all(path)
}

fn file_exists<P: AsRef<Path>>(path: P) -> bool {
    path.as_ref().is_file()
}

fn create_empty_file<P: AsRef<Path>>(path: P) -> io::Result<()> {
    // Attempt to create the file. If it already exists, it will be truncated to zero length.
    File::create(path)?;
    Ok(())
}

fn delete_file_if_exists<P: AsRef<Path>>(path: P) -> io::Result<()> {
    match fs::remove_file(&path) {
        Ok(_) => {
            println!("File '{}' has been deleted.", path.as_ref().display());
            Ok(())
        }

        Err(ref e) if e.kind() == io::ErrorKind::NotFound => {
            println!(
                "File '{}' does not exist. No action taken.",
                path.as_ref().display()
            );
            Ok(())
        }
        Err(e) => Err(e),
    }
}

impl Safener {
    pub fn new(path: String) -> Self {
        let sentinel_file = format!("{}/{}", &path, SENTINEL_FILE);
        let s = Self {
            path,
            sentinel_file,
        };
        
        // to set "unsafe by default", create the file
        // s.create_sentinel_file().unwrap();
        let r = s.set_safe();
        println!("{:?}", r);
        s
    }

    fn create_sentinel_file(&self) -> io::Result<()> {
        create_directories(&self.path)?;

        create_empty_file(&self.sentinel_file)
    }

    pub fn get_path(&self) -> String {
        self.path.clone()
    }

    pub fn set_safe(&self) -> io::Result<()> {
        delete_file_if_exists(&self.sentinel_file)
    }

    pub fn set_unsafe(&self) -> io::Result<()> {
        self.create_sentinel_file()
    }

    pub fn is_safe(&self) -> bool {
        let safe = !file_exists(&self.sentinel_file);

        println!("Sentinel is {}", &safe);
        safe
    }
}
