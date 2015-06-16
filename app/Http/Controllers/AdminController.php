<?php
namespace DreamFactory\Http\Controllers;

class AdminController extends Controller
{
    /**
     * Create new admin controller.
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * View for admin panel.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        return view('admin');
    }
}