<?php

namespace DreamFactory;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

#[Fillable('name', 'email', 'password')]
#[Hidden('password', 'remember_token')]
class User extends Authenticatable
{
    use Notifiable;
}
